require 'bundler'
Bundler.require
require 'sinatra/activerecord/rake'
require 'rake/testtask'
Dir.glob('rake/*.rake').each { |r| load r }

Rake::TestTask.new do |t|
  t.deps = ['db:test:prepare']
  t.test_files = FileList['test/test_helper.rb']
  t.warning = false
end
