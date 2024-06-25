class Equipment < ApplicationRecord
  belongs_to :inventory
  validates :name, :slot, presence: true
end
