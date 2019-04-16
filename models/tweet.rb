# Represents the db's Tweet table
class Tweet < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: :author_id
  has_many :tweet_tags
  has_many :hashtags, through: :tweet_tags
  has_many :mentions
  has_many :mentioned_users, through: :mentions
  has_many :timeline_pieces
  has_many :timeline_users, through: :timeline_pieces, source: :timeline_owner
end
