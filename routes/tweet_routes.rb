# Holds all tweet-related routing logic (viz., timeline & new tweet)

# Main/Timeline view
get '/' do
  enforce_authentication
  # puts "\n\nHERE ARE YOUR PARAMS\n#{params}\n\n"

  user_id = session[:user] ? session[:user].id : params[:user_id]
  @timeline_html = REDIS_TIMELINE_HTML.get(user_id)
  erb :timeline
end

# Returns/renders new Tweet view
get '/tweets/new' do
  enforce_authentication
  erb :new_tweet
end

# Handles new tweet post by placing a task in the appropriate queue
post '/tweets/new' do
  author = session[:user]
  new_tweet = {
    author_id: author.id,
    author_handle: author.handle,
    body: params[:tweet_body],
    created_on: DateTime.now
  }
  create_and_publish_tweet(new_tweet)

  # tweet_as_param = new_tweet.map { |k, v| "#{k}=#{v}" }.join('&')
  # redirect("/?#{tweet_as_param}")
end
