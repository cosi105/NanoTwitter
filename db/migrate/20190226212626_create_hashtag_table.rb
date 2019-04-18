# Initializes the db's Hashtag table
class CreateHashtagTable < ActiveRecord::Migration[5.2]
  def change
    create_table :hashtags do |t|
      t.text :name
    end
  end
end
