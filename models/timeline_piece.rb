# Represents the db's Timeline_piece table
class TimelinePiece < ActiveRecord::Base
  belongs_to :timeline_owner
  belongs_to :tweet
end
