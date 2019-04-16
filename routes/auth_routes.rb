# Holds all authentication-related route handling.

# Render registration page
get '/register' do
  erb :register, layout: false
end

# Register new user (if valid)
post '/register' do
  user = register(params)
  if user.nil?
    redirect '/register'
  else
    redirect '/tweets'
  end
end

# Render login page
get '/login' do
  erb :login, layout: false
end

# Logs user in (if authorized)
# ? Also triggers precaching?
post '/login' do
  user = login(params)
  if user.nil?
    redirect '/login'
  else
    # Start precaching...?
    redirect '/tweets'
  end
end
