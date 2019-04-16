# NOTE: This is for the original/normalized CSV files
def get_csv(model)
  CSV.read(open("#{ENV['CSV_GIST_ROOT_NORMALIZED']}#{model}.csv"))
end

def load_seed(model_params, model_class)
  i = 0
  size = model_params.size
  class_name = model_class.name
  model_params.each do |params|
    model_class.new(params).save(validate: false)
    puts "#{class_name} #{i += 1} / #{size}"
  end
end

require 'csv'
user_rows = get_csv('users')
tweet_rows = get_csv('tweets')
follow_rows = get_csv('follows')
timeline_piece_rows = get_csv('timeline_pieces')

handle_map = {}
mapped_user_rows = user_rows.map do |row|
  id = row[0]
  name = row[1]
  handle_map[row[0].to_sym] = "@#{name}#{id}".downcase
  {
    id: id,
    name: name,
    handle: "@#{name}#{id}".downcase,
    password: "@#{name}#{id}".downcase
  }
end

mapped_follow_rows = follow_rows.map do |row|
  {
    follower_id: row[0],
    followee_id: row[1],
    follower_handle: handle_map[row[0].to_sym],
    followee_handle: handle_map[row[1].to_sym]
  }
end

tweet_map = {}
i = 0
mapped_tweet_rows = tweet_rows.map do |row|
  i += 1
  tweet_map[i.to_s.to_sym] = {
    author_id: row[0],
    body: row[1],
    created_on: DateTime.strptime(row[2], '%Y-%m-%d %H:%M:%S %z'),
    author_handle: handle_map[row[0].to_sym]
  }
  tweet_map[i.to_s.to_sym]
end

mapped_timeline_piece_rows = timeline_piece_rows.map do |row|
  {
    timeline_owner_id: row[0],
    tweet_id: row[1],
    tweet_body: tweet_map[row[1].to_sym][:body],
    tweet_created_on: tweet_map[row[1].to_sym][:created_on],
    tweet_author_handle: tweet_map[row[1].to_sym][:author_handle]
  }
end

[
  [mapped_user_rows, User],
  [mapped_tweet_rows, Tweet],
  [mapped_follow_rows, Follow],
  [mapped_timeline_piece_rows, TimelinePiece]
].each { |arr| load_seed(arr[0], arr[1]) }

User.create(
  id: User.last.id + 1,
  name: 'testuser',
  handle: 'testuser@sample.com',
  password: 'password'
)
