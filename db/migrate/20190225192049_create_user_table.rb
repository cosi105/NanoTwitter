# Initializes the db's User table
class CreateUserTable < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :handle
      t.string :password_digest
    end
  end
end
