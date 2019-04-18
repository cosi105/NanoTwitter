# Add indexes to db
class AddIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :handle, unique: true

    add_index :tweets, :author_id

    add_index :follows, :follower_id
    add_index :follows, :followee_id
    add_index :follows, %i[follower_id followee_id], unique: true

    add_index :timeline_pieces, :timeline_owner_id
    add_index :timeline_pieces, :tweet_created_on
  end
end
