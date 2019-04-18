# Holds cache/Redis-related helper functions.

# Gets env-specific Redis object
def get_redis_object
  redis = nil
  if Sinatra::Base.production?
    configure do
      uri = URI.parse(ENV['REDISTOGO_URL'])
      redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    end
  else
    redis = Redis.new
  end
  redis.flushall
  redis
end

# Initialize a Redis object for use globally
REDIS = get_redis_object

# Pre-caches a mapping of all user handles to user ids
require_relative '../models/user'
Thread.new do
  i = 0
  count = Tweet.count
  User.all.each do |user|
    REDIS.set("#{user.handle}:user_id", user.id)
    user.tweets.each { |tweet| REDIS.lpush("#{user.handle}:tweet_ids", tweet.id) }
    puts "Seeded user #{i+=1} of #{count}!"
  end
  Tweet.all.each do |tweet|
    words = tweet.body.split.map { |w| w.downcase }
    words.each do |word|
      word.chop! if word[word.length-1] == '!'
      REDIS.lpush("#{word}", tweet.id)
    end
    puts "Seeded tweet #{i+=1} of #{count}!"
  end
  puts 'Seeded redis!'
end
