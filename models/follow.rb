# Represents the db's Follow table
class Follow < ActiveRecord::Base
  belongs_to :follower, class_name: 'User'
  belongs_to :followee, class_name: 'User'

  # No two follows should have the same follower and followee
  validates_uniqueness_of :follower_id, scope: %i[followee_id]

  # Follower != Followee (user can't follow themselves)
  validates :follower_id, exclusion: { in: ->(follow) { [follow.followee_id] } }
end
