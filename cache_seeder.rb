# Holds helper functions used to seed Redis caches via RabbitMQs.
require './app'
require 'httparty'

def ping_apps
  urls = %w[nano-twitter nano-twitter-follow-data nano-twitter-searcher nano-twitter-timeline-data nano-twitter-tweet-html]
  urls.map! { |s| "https://#{s}.herokuapp.com/" }
  urls.each do |url|
    HTTParty.get(url)
    puts "Pinged #{url}"
  end
end

def caffeinate_apps
  loop do
    ping_apps
    5.times { sleep 60 }
  end
end

# Follows seeding
def publish_follow_data_seed
  puts 'Seeding Follows...'
  follow_data_seed = CHANNEL.queue('follow.data.seed')
  follows_data_payload = Follow.all.map { |f|
    {
      follower_id: f.follower_id,
      follower_handle: f.follower_handle,
      followee_id: f.followee_id,
      followee_handle: f.followee_handle
    }
  }
  publish(follow_data_seed, follows_data_payload)
  puts 'Finished seeding Follows!'
end

# Timeline seeding: TimelineData
def publish_timeline_data_seed
  puts 'Seeding Tweet data...'
  seeded_tweet_ids = Set.new
  User.all.each do |user|
    timeline_tweets = user.timeline_tweets
    payload = {
      owner_id: user.id,
      sorted_tweets: tweets_as_payload(timeline_tweets.order(:id))
    }
    %w[tweet_html timeline_data].map { |s| CHANNEL.queue("timeline.data.seed.#{s}") }.each { |queue| publish(queue, payload) }
    seeded_tweet_ids << timeline_tweets
    seeded_tweet_ids.flatten!
  end
  orphans = (Tweet.all.pluck(:id) - seeded_tweet_ids.to_a).map { |i| Tweet.find(i) }
  payload = {
    owner_id: -1,
    sorted_tweets: tweets_as_payload(orphans.sort)
  }
  %w[tweet_html timeline_data].map { |s| CHANNEL.queue("timeline.data.seed.#{s}") }.each { |queue| publish(queue, payload) }
  puts 'Finished seeding Tweet data!'
end

def tweets_as_payload(tweets)
  tweets.map { |t|
    {
      tweet_id: t.id,
      tweet_body: t.body,
      tweet_created: t.created_on,
      author_id: t.author_id,
      author_handle: t.author_handle
    }
  }
end

# Pre-caches a mapping of all user handles to user ids
def cache_user_data_seed
  puts 'Loading User data...'
  User.all.each do |user|
    REDIS_USER_DATA.set("#{user.handle}:user_id", user.id)
    user.tweets.each { |tweet| REDIS_USER_DATA.lpush("#{user.handle}:tweet_ids", tweet.id) }
  end
  puts 'Finished loading User data!'
end

def publish_cache_purge
  %w[searcher timeline_data tweet_html].each { |s| blank_publish("cache.purge.#{s}") }
end

# ping_apps
# Thread.new { caffeinate_apps }

# Flush everything before seeding
[REDIS_FOLLOW_DATA, REDIS_FOLLOW_HTML, REDIS_SEARCH_HTML, REDIS_TIMELINE_HTML, REDIS_USER_DATA].each(&:flushall)

puts 'Starting seeding...'
purge_all_queues
purge_all_local_caches
publish_cache_purge
publish_timeline_data_seed
publish_follow_data_seed
cache_user_data_seed
puts 'Finished seeding!'
