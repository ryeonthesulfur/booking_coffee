class Reservation < ApplicationRecord
  belongs_to :user
  belongs_to :seat

  with_options presence: true do
    validates :start_time
    validates :end_time
    validates :num_people
    validates :total_price
    validates :status
  end

  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    errors.add(:end_time, "は開始時間より後にしてください") if end_time <= start_time
  end
end
