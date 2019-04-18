# Represents the db's User table
class User < ActiveRecord::Base
  has_secure_password
  validates :handle, presence: true, uniqueness: true

  has_many :follows_from_me, class_name: 'Follow', foreign_key: :follower_id
  has_many :followees, through: :follows_from_me

  # Followers are people who follow this user
  has_many :follows_to_me, class_name: 'Follow', foreign_key: :followee_id
  has_many :followers, through: :follows_to_me

  has_many :tweets, foreign_key: :author_id
  has_many :tweet_tags, through: :tweets
  has_many :timeline_pieces, foreign_key: :timeline_owner_id
  has_many :timeline_tweets, through: :timeline_pieces, source: :tweet
  has_many :mentions, foreign_key: :mentioned_user_id
  has_many :mentioned_tweets, through: :mentions, source: :tweet

end
