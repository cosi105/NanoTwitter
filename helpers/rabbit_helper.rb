# Holds RabbitMQ-related helper functions

# Initialize RabbitMQ object & connection appropriate to
# the current env (viz., local vs. prod)
if Sinatra::Base.production?
  # Determine what env variable(s) are needed in prod
else
  rabbit = Bunny.new(automatically_recover: false)
end
rabbit.start
channel = rabbit.create_channel
RABBIT_EXCHANGE = channel.default_exchange
NEW_TWEET = channel.queue('new.tweet.data') # Subs: TimelineData, TimelineHTML
NEW_TIMELINE = channel.queue('new.timeline.data') # Sub: TimelineData
NEW_FOLLOW = channel.queue('new.follow.html') # Sub: FollowData

def rabbit_new_tweet(body)
  publish(body, NEW_TWEET)
end
# !!! Should we close the connection at any point? !!!
# Initialize a RabbitMQ object for use globally

def publish(body, queue)
  RABBIT_EXCHANGE.publish(body, routing_key: queue.name)
end

rabbit_new_tweet 'Hell. oh, world...'