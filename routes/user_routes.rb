# Holds all user-related route handling.

# Render view of user's followers
get '/users/followers' do
  user = session[:user]
  @followers = user.followers
  erb :user_follower
end

# Render view of the people the current user is following.
get '/users/following' do
  user = session[:user]
  @followees = user.followees
  erb :user_following
end

# Handles following a new user
post '/users/following' do
  follower = session[:user]

  followee_handle = params[:followee_handle]
  followee_id = REDIS.get("#{followee_handle}:user_id")
  rabbit_new_follow(follower.id, follower.handle, followee_id, followee_handle)

  followee_tweet_ids = REDIS.get("#{followee_id}:tweet_ids")
  rabbit_new_follow_timeline(follower.id, followee_tweet_ids)

  Thread.new do
    Follow.create(follower_id: follower.id, followee_id: followee_id)
    followee_tweet_ids.each { |t| TimelinePiece.create(timeline_owner_id: follower.id, tweet_id: t.to_i) }
  end
  redirect '/users'
end
