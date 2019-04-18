# Initializes db's Follow table
class CreateFollowTable < ActiveRecord::Migration[5.2]
  def change
    create_table :follows do |t|
      t.integer :follower_id
      t.integer :followee_id
      t.string :follower_handle
      t.string :followee_handle
    end
  end
end
