# A to seed Redis caches via CSVs stored as GitHub gists.
require './app'
require 'httparty'
require 'open-uri'

# Pre-caches a mapping of all user handles to user ids
def cache_user_data_seed
  puts 'Seeding user data...'
  REDIS_USER_DATA.flushall
  whole_csv = CSV.parse(open("#{ENV['CACHE_SEED_ROOT']}user_data.csv"))
  list_keys = whole_csv.select { |row| row[0].include? 'tweet_ids' }
  string_keys = whole_csv - list_keys
  string_keys.each { |line| REDIS_USER_DATA.set(line[0], line[1]) }
  list_keys.each do |line|
    key = line[0]
    values = line.drop(1)
    REDIS_USER_DATA.rpush(key, values)
  end
  puts 'Seeded user data!'
end

def send_csv(arr)
  app, csv, route = arr
  path = "#{ENV["#{app}_URL"]}/seed#{route}"
  Thread.new do
    puts "Seeding #{csv}..."
    HTTParty.post(path, query: { csv_url: "#{ENV['CACHE_SEED_ROOT']}#{csv}.csv" })
    puts "Seeded #{csv}!"
  end
end

puts 'Starting seeding...'

seed_params = [%w[FOLLOW_DATA follow_data /data], %w[FOLLOW_DATA follow_html /html],
               %w[SEARCHER search_data], %w[TWEET_HTML search_html /search],
               %w[TIMELINE_DATA timeline_data], %w[TWEET_HTML timeline_html /timeline],
               %w[TWEET_HTML tweet_html /tweets]]

seed_threads = seed_params.map { |arr| send_csv(arr) }
seed_threads << Thread.new { cache_user_data_seed }
seed_threads.each(&:join)

puts 'Finished seeding!'
