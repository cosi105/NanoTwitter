# Holds all tweet-related routing logic (viz., timeline & new tweet)

# Returns/renders new Tweet view
get '/tweets/new' do
  # Authenticate first
  # byebug
  erb :new_tweet
end

# Handles new tweet post by placing a task in the appropriate queue
post '/tweets/new' do
  # Authenticate?
  author = session[:user]
  new_tweet = Tweet.create(
    author_id: author.id,
    author_handle: author.handle,
    body: params[:tweet][:body],
    created_on: DateTime.now
  )
  rabbit_new_tweet(author.id, author.handle, new_tweet.id, new_tweet.body, new_tweet.created_on)

  Thread.new do
    followers = author.follows_to_me.pluck(:follower_id)
    followers.each { |f| TimelinePiece.create(timeline_owner_id: f, tweet_id: new_tweet.id) }
  end
end
