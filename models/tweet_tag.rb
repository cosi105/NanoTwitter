# Represents the db's Tweet_Tag table
class TweetTag < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :hashtag
end
