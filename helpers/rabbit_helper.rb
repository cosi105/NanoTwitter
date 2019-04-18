# Holds RabbitMQ-related helper functions

# Initialize RabbitMQ object & connection appropriate to
# the current env (viz., local vs. prod)
if Sinatra::Base.production?
  rabbit = Bunny.new(ENV['CLOUDAMQP_URL'])
else
  rabbit = Bunny.new(automatically_recover: false)
end
rabbit.start
channel = rabbit.create_channel
RABBIT_EXCHANGE = channel.default_exchange

# author_id, tweet_id, tweet_body
NEW_TWEET = channel.queue('new_tweet.tweet_data')
# follower_id, follower_handle, followee_id, followee_handle
NEW_FOLLOW_USER_DATA = channel.queue('new_follow.user_data')
# follower_id: [tweet_ids…]
NEW_FOLLOW_TIMELINE_DATA = channel.queue('new_follow.timeline_data')

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

# # Publishes JSON payloads to seed queues for microservices
# def publish_seeds
#   # Follows
#   follow_data_seed = channel.queue('follow.data.seed')
#   follows = Follows.all.map {|f| f.}

#   # Tweets
#   searcher_seed = channel.queue('searcher.seed')
#   tweet_html_router_seed = channel.queue('tweet.html.router.seed')
  
#   # Timeline Pieces
#   timeline_data_seed = channel.queue('timeline.data.seed')
#   timeline_html_seed = channel.queue('timeline.html.seed')
# end
