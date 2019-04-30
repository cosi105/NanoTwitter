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
  user = session[:user]
  followee_handle = params[:followee_handle]
  follow_params = {
    follower_id: user.id,
    follower_handle: user.handle,
    followee_id: REDIS_USER_DATA.get("#{followee_handle}:user_id").to_i,
    followee_handle: followee_handle
  }
  create_and_publish_follow(follow_params)
  redirect '/users'
end
