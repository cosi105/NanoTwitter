# Represents the db's Hashtag table
class Hashtag < ActiveRecord::Base
  has_many :tweet_tags
  has_many :tweets, through: :tweet_tags
end
