get '/search' do
  @timeline_html = REDIS_SEARCH_HTML.get("#{params[:token]}:joined")
  erb :timeline
end

# Example
# http://localhost:4567/test/user/tweet?user_id=1000&tweet_count=5&user_handle=ahmed1000
get '/test/tweet' do
  num_tweets = params[:tweet_count].to_i
  # NOTE: We're hard-coding a sample Tweet body only to
  # simulate receiving one (already formed) as a parameter,
  # rather than generating one on the fly, which would incur
  # an unrealistic time/compute cost on the server side.
  # We promise we know good code style practices. <3
  test_tweet_body = "I'd never hard-code a test Tweet, not even for debugging purposes!"
  tweet_params = {
    author_id: params[:user_id].to_i,
    author_handle: "@#{params[:user_handle]}",
    body: test_tweet_body,
    created_on: DateTime.now
  }
  puts 'Built tweet params'
  num_tweets.times { create_and_publish_tweet(tweet_params) }
  200
end
