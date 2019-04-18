def reset_id_count
  ActiveRecord::Base.connection.tables.each do |t|
    ActiveRecord::Base.connection.reset_pk_sequence!(t)
  end
end

def get_credentials
  url = ENV['DATABASE_URL'].dup
  url.slice!(0..'postgres://'.length-1)
  username = url.slice!(0..url.index(':')).slice(0..-2)
  password = url.slice!(0..url.index('@')).slice(0..-2)
  host = url.slice!(0..url.index(':')).slice(0..-2)
  port = url.slice!(0..url.index('/')).slice(0..-2)
  dbname = url

  return password, "-h #{host} -p #{port} -d #{dbname} -U #{username}"
end

namespace :db do
  desc 'Creates a SQL dump file from the database'
  task :dump do
    file_path = "#{ENV['PG_DUMP_PATH']}/#{ENV['PG_DUMP_FILE']}"
    system "pg_dump #{ENV['PG_HOST']} -a -f #{file_path}"
    puts "Created SQL dump at #{file_path}"
  end

  namespace :dump do
    desc 'Loads the database from a SQL dump file'
    task seed: ['db:migrate'] do
      require 'open-uri'
      ActiveRecord::Base.subclasses.each(&:delete_all)
      reset_id_count
      puts 'Downloading SQL data...'
      sql_file = open(ENV['SQL_DUMP_URL'])
      puts 'Downloaded SQL data!'
      puts 'Loading seed database...'
      if Sinatra::Base.production?
        password, credentials = get_credentials
        system "set PGPASSWORD=#{password}; psql -f #{credentials} #{sql_file.path}"
      else
        system "psql -f #{sql_file.path}"
      end
      reset_id_count
      sql_file.close!
      puts 'Loaded seed database!'
    end
  end
end
