namespace :db do
  desc 'Creates a SQL dump file from the database'
  task :dump do
    file_path = "#{ENV['PG_DUMP_PATH']}/#{ENV['PG_DUMP_FILE']}"
    system "pg_dump #{ENV['PG_HOST']} -a -f #{file_path}"
    puts "Created SQL dump at #{file_path}"
  end

  namespace :dump do
    desc 'Loads the database from a SQL dump file'
    task seed: ['db:drop', 'db:create', 'db:migrate'] do
      puts 'Downloading SQL data...'
      sql_file = open(ENV['SQL_DUMP_URL'])
      puts 'Downloaded SQL data!'
      puts 'Loading seed database...'
      system "psql -f #{sql_file.path} #{ENV['PG_HOST']}"
      ActiveRecord::Base.connection.tables.each do |t|
        ActiveRecord::Base.connection.reset_pk_sequence!(t)
      end
      sql_file.close!
      puts 'Loaded seed database!'
    end
  end
end
