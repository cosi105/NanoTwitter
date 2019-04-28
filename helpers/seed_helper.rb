# Holds helper functions used to seed Redis caches via RabbitMQs.
require_relative 'rabbit_helper'
require_relative 'redis_helper'

# Follows seeding
def publish_follows_seeds
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
    publish(follow_data_seed, follows_data_payload)
    puts 'Finished seeding Follows!'
end

# Tweets seeding: TweetHTML & Searcher
def publish_tweet_seeds
  tweet_html_payload = []
  searcher_payload = []
  tweet_html_router_seed = CHANNEL.queue('tweet.html.router.seed')
  searcher_seed = CHANNEL.queue('searcher.seed')
  Tweet.all.each do |t|
    tweet_html_payload << {
      author_id: t.author_id,
      author_handle: t.author_handle,
      tweet_id: t.id,
      tweet_body: t.body,
      tweet_created: t.created_on
    }
    searcher_payload << {
      tweet_id: t.id,
      tweet_body: t.body
    }
  end
  publish(tweet_html_router_seed, tweet_html_payload)
  publish(searcher_seed, searcher_payload)
  puts 'Finished seeding Tweets!'
end

# Timeline seeding: TimelineData
def publish_timeline_seeds
  timeline_data_seed = CHANNEL.queue('tweet.data.seed')
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

publish_follows_seeds
publish_tweet_seeds
publish_timeline_seeds
