# Initializes the db's Mention table
class CreateMentionTable < ActiveRecord::Migration[5.2]
  def change
    create_table :mentions do |t|
      t.integer :tweet_id
      t.integer :mentioned_user_id
    end
  end
end
