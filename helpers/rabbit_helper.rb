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
# follower_id, follower_handle, followee_id, followee_handle
NEW_FOLLOW_USER_DATA = CHANNEL.queue('new_follow.user_data')
# follower_id: [tweet_ids…]
NEW_FOLLOW_TIMELINE_DATA = CHANNEL.queue('new_follow.timeline_data')

# Generate new tweet payload as json object & publish it to queue.
def rabbit_new_tweet(author_id, tweet_id, tweet_body)
  payload = {
    author_id: author_id,
    tweet_id: tweet_id,
    tweet_body: tweet_body
  }.to_json
  publish(NEW_TWEET, payload)
end

# Generate new follow payload as json object & publish it to queue.
def rabbit_new_follow(follower_id, follower_handle, followee_id, followee_handle)
  payload = {
    follower_id: follower_id,
    follower_handle: follower_handle,
    followee_id: followee_id,
    followee_handle: followee_handle
  }.to_json
  publish(NEW_FOLLOW_USER_DATA, payload)
end

# Generate new follow timeline payload as json object & publish it to queue.
def rabbit_new_follow_timeline(follower_id, followee_tweet_ids)
  payload = {
    follower_id: follower_id,
    followee_tweets: followee_tweet_ids
  }.to_json
  publish(NEW_FOLLOW_TIMELINE_DATA, payload)
end

# Publishes a payload to a queue
def publish(queue, payload)
  RABBIT_EXCHANGE.publish(payload, routing_key: queue.name)
end

# Publishes JSON payloads to seed queues for microservices
def publish_seeds
  # Follows
  puts 'Starting seeding!'
  follow_data_seed = CHANNEL.queue('follow.data.seed')
  follows_data_payload = []
  Follow.all.each do |f|
    follows_data_payload << {
      follower_id: f.follower_id,
      follower_handle: f.follower_handle,
      followee_id: f.followee_id,
      followee_handle: f.followee_handle
    }
  end
  publish(follow_data_seed, follows_data_payload.to_json)
  puts 'Finished seeding!'
  # Tweets
  searcher_seed = CHANNEL.queue('searcher.seed')
  tweet_html_router_seed = CHANNEL.queue('tweet.html.router.seed')

  # Timeline Pieces
  timeline_data_seed = CHANNEL.queue('timeline.data.seed')
  timeline_html_seed = CHANNEL.queue('timeline.html.seed')
end

publish_seeds
