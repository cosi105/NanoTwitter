#  Holds authentication-related helper functions

# 1. Get username & password from params
# 2. Check for blank params
# 3. Check cache to see if username is taken
# 4. Create user
def register(params)
  user_handle = params[:handle].downcase
  password = params[:password]
  user = get_user_from_handle(user_handle)
  name = params[:name]
  if user_handle.blank? || password.blank? || name.blank? || !user.nil?
    status 403 # Forbidden
    nil
  else
    status 201 # Created
    user = User.create(name: name, handle: user_handle, password: password)
    REDIS_USER_DATA.set(user.handle, user.id)
    follow_params = {
      follower_id: user.id,
      follower_handle: user.handle,
      followee_id: user.id,
      followee_handle: user.handle
    }
    create_and_publish_follow(follow_params)
    set_session_user(user)
  end
end

# Set session's user and return the user
# Also triggers pre-caching
def set_session_user(user)
  session[:user] = user
  user
end

# Given a user handle, returns a user id (if found)
def get_user_from_handle(user_handle)
  if REDIS_USER_DATA.exists(user_handle)
    User.find(REDIS_USER_DATA.get(user_handle).to_i)
  else
    User.find_by(handle: user_handle)
  end
end

# Logs user in, if authenticated.
def login(params)
  user_handle = params[:handle]
  unless user_handle.nil?
    user = get_user_from_handle(user_handle)
    return set_session_user(user) if user && user.authenticate(params[:password])
  end
  nil
end
