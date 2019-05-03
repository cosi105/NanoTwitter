# Holds all user-related route handling.

# Render view of user's followers
get '/users/followers' do
  enforce_authentication
  user = session[:user]
  @follows = REDIS_FOLLOW_HTML.lrange("#{user.id}:followers", 0, -1)
  @current_user = user.name
  @action = 'follow'
  erb :user_follows
end

# Render view of the people the current user is following.
get '/users/following' do
  enforce_authentication
  user = session[:user]
  @follows = REDIS_FOLLOW_HTML.lrange("#{user.id}:followees", 0, -1)
  @current_user = user.name
  @action = 'unfollow'
  erb :user_follows
end

get '/users/profile' do
  enforce_authentication
  @user = session[:user]
  @current_user = @user.name
  erb :profile
end

post '/users/follow' do
  new_follow = {
    remove: params[:remove], # Flags unfollow vs follow
    follower_id: session[:user].id,
    follower_handle: session[:user].handle,
    followee_handle: params[:followee_handle],
    followee_id: REDIS_USER_DATA.get("#{params[:followee_handle]}:user_id").to_i
  }
  create_and_publish_follow(new_follow)
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
