# Initializes db's Timeline Piece table
class CreateTimelinePieceTable < ActiveRecord::Migration[5.2]
  def change
    create_table :timeline_pieces do |t|
      t.integer :timeline_owner_id
      t.integer :tweet_id
      t.string :tweet_body
      t.datetime :tweet_created_on
      t.string :tweet_author_handle
    end
  end
end
