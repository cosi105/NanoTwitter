# Holds all tweet-related routing logic (viz., timeline & new tweet)

get '/tweets/new' do
  # Authenticate first
  erb :new_tweet
end

# Handles new tweet post by placing a task in the appropriate queue
post '/tweets/new' do
  # Authenticate?
  # Get & enqueue new tweet payloads (data & HTML)
end

# Handles new follow post by placing a task in the appropriate queue
post '/follows/new' do
  # Authenticate?
  # Get & enqueue new tweet payloads (data & HTML)
end

# Need methods to generate payloads for each microservice:
# FollowsData
# FollowsHTML
# TimelineData
# TimelineHTML
