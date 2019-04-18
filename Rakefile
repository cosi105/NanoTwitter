require 'bundler'
Bundler.require
require 'sinatra/activerecord/rake'
require 'rake/testtask'
require './app'

Rake::TestTask.new do |t|
  t.deps = ['db:test:prepare']
  t.test_files = FileList['test/test_helper.rb']
  t.warning = false
end
