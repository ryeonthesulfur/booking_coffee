class Seat < ApplicationRecord
  has_many :reservations
  validates :seat_number, presence: true, uniqueness: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_per_hour, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
