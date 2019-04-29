# Holds helper functions used to seed Redis caches via RabbitMQs.
require_relative 'rabbit_helper'
require_relative 'redis_helper'

# Follows seeding
def publish_follow_data_seed
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
  puts 'Finished seeding Follows!'
end

# Tweets seeding: TweetHTML & Searcher
def publish_tweet_data_seed
  tweet_data_seed = CHANNEL.queue('tweet.data.seed')
  tweet_data_payload = []
  Tweet.all.each do |t|
    tweet_html_payload << {
      author_id: t.author_id,
      author_handle: t.author_handle,
      tweet_id: t.id,
      tweet_body: t.body,
      tweet_created: t.created_on
    }
  end
  publish(tweet_data_seed, tweet_data_payload.to_json)
  puts 'Finished seeding Tweets!'
end

# Timeline seeding: TimelineData
def publish_timeline_seeds
  timeline_data_seed = CHANNEL.queue('timeline.data.seed')
  payload = []
  User.all.each do |user|
    tweet_data = []
    user.timeline_tweets.order(:id).each do |t|
      tweet_data << {
        tweet_id: t.id,
        tweet_body: t.body,
        tweet_created: t.created_on,
        author_id: t.author_id,
        author_handle: t.author_handle
      }
    end
    payload << { owner_id: user.id, sorted_tweets: tweet_data }
  end
  publish(timeline_data_seed, payload)
  puts 'Finished seeding Tweet data!'
end

# seed_follows
# seed_tweets
# seed_timelines

[REDIS_FOLLOW_HTML, REDIS_SEARCH_HTML, REDIS_TIMELINE_HTML, REDIS_USER_DATA].each(&:flushall)

# Pre-caches a mapping of all user handles to user ids
require_relative '../models/user'
Thread.new do
  User.all.each do |user|
    REDIS.set("#{user.handle}:user_id", user.id)
    user.tweets.each { |tweet| REDIS.lpush("#{user.handle}:tweet_ids", tweet.id) }
  end
end
