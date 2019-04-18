# Initializes the db's Tweet table
class CreateTweetTable < ActiveRecord::Migration[5.2]
  def change
    create_table :tweets do |t|
      t.string :body
      t.datetime :created_on
      t.integer :author_id
      t.string :author_handle
    end
  end
end
