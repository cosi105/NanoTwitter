# Holds cache/Redis-related helper functions.

# Gets env-specific Redis object
def redis_from_uri(key)
  uri = URI.parse(ENV[key])
  Redis.new(host: uri.host, port: uri.port, password: uri.password)
end

if Sinatra::Base.production?
  configure do
    REDIS_FOLLOW_DATA, REDIS_FOLLOW_HTML, REDIS_SEARCH_HTML, REDIS_TIMELINE_HTML, REDIS_USER_DATA = %w[FOLLOW_DATA_URL FOLLOW_HTML_URL SEARCH_HTML_URL TIMELINE_HTML_URL USER_DATA_URL].map { |s| redis_from_uri(s) }
  end
else
  REDIS_FOLLOW_DATA, REDIS_FOLLOW_HTML, REDIS_TIMELINE_HTML, REDIS_USER_DATA = [6385, 6380, 6379, 6381].map { |i| Redis.new(port: i) }
  REDIS_SEARCH_HTML = Redis.new(uri: 'redis://h:pb7e9e241a7563f3a6dde3cdca026c52a760e012ab4f36d4a16b9c2cdebe426a8@ec2-18-211-194-247.compute-1.amazonaws.com:24309')
end
