class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :seat

  validates :start_time, presence: true
  validates :num_people, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :phone_number, presence: true, format: { with: /\A\d{10,11}\z/ }
end
