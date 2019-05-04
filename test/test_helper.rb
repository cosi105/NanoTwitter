# This file is a DRY way to set all of the requirements
# that our tests will need, as well as a before statement
# that purges the database and creates fixtures before every test

ENV['APP_ENV'] = 'test'
require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require_relative '../app'
ENV['PGDATABASE'] = ActiveRecord::Base.subclasses.first.connection.current_database

def app
  Sinatra::Application
end

describe 'NanoTwitter' do
  include Rack::Test::Methods
  before do
    ActiveRecord::Base.subclasses.each(&:delete_all)
    purge_all_queues
    publish_cache_purges
    purge_all_local_caches
    names = %w[ari brad yang pito]
    users = names.map { |s| User.create(name: s.capitalize, handle: "@#{s}", password: "@#{s}") }
    @ari, @brad, @yang, @pito = users
  end
  # Define file path pattern for identifying test files:
  Dir['test/*_test.rb'].each do |file|
    file.slice!(0..(file.index('/')))
    require_relative file
  end
end
