class Room < ApplicationRecord
  has_many :characters, foreign_key: :current_room_id
  has_many :enemies, dependent: :destroy
  has_many :items, dependent: :destroy

  belongs_to :north, class_name: 'Room', foreign_key: :north_id, optional: true
  belongs_to :south, class_name: 'Room', foreign_key: :south_id, optional: true
  belongs_to :east, class_name: 'Room', foreign_key: :east_id, optional: true
  belongs_to :west, class_name: 'Room', foreign_key: :west_id, optional: true

  validates :name, presence: true
  validates :description, presence: true
end
