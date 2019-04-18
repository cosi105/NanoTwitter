# Represents the db's Mention table
class Mention < ActiveRecord::Base
  belongs_to :mentioned_user, class_name: 'User'
  belongs_to :tweet
end
