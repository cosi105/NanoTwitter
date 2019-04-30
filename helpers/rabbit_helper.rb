# Holds RabbitMQ-related helper functions

# Initialize RabbitMQ object & connection appropriate to
# the current env (viz., local vs. prod)
if Sinatra::Base.production?
  rabbit = Bunny.new(ENV['CLOUDAMQP_URL'])
else
  rabbit = Bunny.new(automatically_recover: false)
end
rabbit.start
CHANNEL = rabbit.create_channel
RABBIT_EXCHANGE = CHANNEL.default_exchange

# author_id, tweet_id, tweet_body
NEW_TWEET = CHANNEL.queue('new_tweet.tweet_data')
NEW_TWEET_TO_SEARCH = CHANNEL.queue('new_tweet.searcher.tweet_data')
NEW_TWEET_TO_DB = CHANNEL.queue('new_tweet.to_db')
NEW_FOLLOW_TO_DB = CHANNEL.queue('new_follow.to_db')

# follower_id, follower_handle, followee_id, followee_handle
NEW_FOLLOW_DATA = CHANNEL.queue('new_follow.data')
# follower_id: [tweet_ids…]
NEW_FOLLOW_TIMELINE_DATA = CHANNEL.queue('new_follow.timeline_data')

# MQ to asynchronously update the DB upon receiving a new Tweet
NEW_TWEET_TO_DB.subscribe(block: false) do |delivery_info, properties, body|
  rabbit_new_tweet_db_timelines(JSON.parse(body))
end
NEW_FOLLOW_TO_DB.subscribe(block: false) do |delivery_info, properties, body|
  rabbit_new_follow_db_timelines(JSON.parse(body))
end

# Generate new tweet payload as json object & publish it to queue.
def create_and_publish_tweet(params)
  tweet = Tweet.create(params)
  payload = {
    author_id: tweet.author_id,
    author_handle: tweet.author_handle,
    tweet_id: tweet.id,
    tweet_body: tweet.body,
    tweet_created: tweet.created_on
  }
  publish(NEW_TWEET, payload)
  public(NEW_TWEET_TO_SEARCH, payload)
  publish(NEW_TWEET_TO_DB, {author_id: tweet.author_id, tweet_id: tweet.id})
  puts "Published tweet #{tweet.id}"
end

# Generate new follow payload as json object & publish it to queue.
def create_and_publish_follow(params)
  publish(NEW_FOLLOW_DATA, params)

  followee_tweet_ids = REDIS_USER_DATA.lrange("#{params[:followee_handle]}:tweet_ids", 0, -1)
  payload = { follow_params: params, followee_tweets: followee_tweet_ids }
  publish(NEW_FOLLOW_TO_DB, payload)
  publish(NEW_FOLLOW_TIMELINE_DATA, payload)
end

# Use author_id & tweet_id to
def rabbit_new_tweet_db_timelines(body)
  followers = REDIS_FOLLOW_DATA.lrange("#{body['author_id'].to_i}:follower_ids", 0, -1)
  tweet_id = body['tweet_id'].to_i
  tweet = Tweet.find(tweet_id)
  followers.each { |f| TimelinePiece.create(
    tweet_body: tweet.body,
    tweet_created_on: tweet.created_on,
    tweet_author_handle: tweet.author_handle,
    timeline_owner_id: f,
    tweet_id: tweet_id
  ) }
  puts 'Created timeline pieces'
end

def rabbit_new_follow_db_timelines(body)
  follow = Follow.create(body['follow_params'])
  follower_id = follow.follower_id
  body['followee_tweet_ids'].each { |t| TimelinePiece.create(timeline_owner_id: follower_id, tweet_id: t) }
end

# Publishes a new Tweet as a payload in order to consume &
# update follower Timelines in the DB asynchronously.
def publish_new_tweet_internally(body)
  publish(NEW_TWEET_TO_DB, body)
end

# Publishes a payload to a queue
def publish(queue, payload)
  RABBIT_EXCHANGE.publish(payload.to_json, routing_key: queue.name)
end

def purge_all_queues
  %w[new_tweet.tweet_data new_follow.user_data new_follow.timeline_data timeline.data.seed.tweet_html timeline.data.seed.timeline_data searcher.data.seed new_tweet.tweet_data follow.data.seed new_tweet.follower_ids searcher.html new_follow.sorted_tweets].each { |name| CHANNEL.queue(name).purge }
end
