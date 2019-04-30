require 'bundler'
Bundler.require
require 'redis'
require_relative 'version'
Dir.glob('rake/*.rake').each { |r| load r }

enable :sessions

# Sets local env configurations if applicable
unless Sinatra::Base.production?
  require 'dotenv'
  Dotenv.load 'config/local_vars.env'
  require 'pry-byebug'
end

def dir_require(dir_name)
  Dir["#{__dir__}/#{dir_name}/*rb"].each { |file| require file }
end

# Require all model, helper, & view files
%w[models helpers routes].each { |dir| dir_require dir }

get '/search' do
  REDIS_SEARCH_HTML.lrange(params[:token], 0, -1).join
end

# Example
# http://localhost:4567/test/user/tweet?user_id=1000&tweet_count=5&user_handle=ahmed1000
get '/test/user/tweet' do
  num_tweets = params[:tweet_count].to_i
  # NOTE: We're hard-coding a sample Tweet body only to
  # simulate receiving one (already formed) as a parameter,
  # rather than generating one on the fly, which would incur
  # an unrealistic time/compute cost on the server side.
  # We promise we know good code style practices. <3
  test_tweet_body = "brad iS RRREALLY sO tIrEd" # "I'd never hard-code a test Tweet!"
  tweet_params = {
    author_id: params[:user_id].to_i,
    author_handle: "@#{params[:user_handle]}",
    body: test_tweet_body,
    created_on: DateTime.now
  }
  puts 'Built tweet params'
  num_tweets.times { create_and_publish_tweet(tweet_params) }
end
