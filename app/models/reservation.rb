class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :seat
  enum :status, { reserved: 0, using: 1, checked_out: 2 }


  validates :start_time, presence: true
  validates :num_people, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :phone_number, presence: true, format: { with: /\A\d{10,11}\z/ }

  validate :no_overlapping_reservation

private

def no_overlapping_reservation
  overlapping = Reservation
    .where(seat: seat)
    .where(status: [ :reserved, :using ])
    .where("start_time > ? AND start_time < ?", start_time - 3.hours, start_time + 3.hours)
    .where.not(id: id)
    .exists?

  errors.add(:start_time, "はすでに予約が入っています") if overlapping
end
end
