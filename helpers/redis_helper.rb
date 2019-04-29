# Holds cache/Redis-related helper functions.

# Gets env-specific Redis object
def redis_from_uri(key)
  uri = URI.parse(ENV[key])
  Redis.new(host: uri.host, port: uri.port, password: uri.password)
end

if Sinatra::Base.production?
  configure do
    REDIS_FOLLOW_HTML, REDIS_SEARCH_HTML, REDIS_TIMELINE_HTML, REDIS_USER_DATA = %w[FOLLOW_HTML_URL SEARCH_HTML_URL TIMELINE_HTML_URL USER_DATA_URL].map { |s| redis_from_uri(s) }
  end
else
  REDIS_FOLLOW_HTML, REDIS_SEARCH_HTML, REDIS_TIMELINE_HTML, REDIS_USER_DATA = [6380, 6382, 6379, 6381].map { |i| Redis.new(port: i) }
end
