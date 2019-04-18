# Initializes db's Tweet Tag table
class CreateTweetTagTable < ActiveRecord::Migration[5.2]
  def change
    create_table :tweet_tags do |t|
      t.integer :hashtag_id
      t.integer :tweet_id
    end
  end
end
