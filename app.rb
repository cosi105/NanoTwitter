require 'bundler'
Bundler.require
require 'redis'
require_relative 'version'
Dir.glob('rake/*.rake').each { |r| load r }

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

# Dir["#{__dir__}/views/*.erb"].each { |file| require file }
