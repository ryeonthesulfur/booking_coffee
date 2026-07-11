class CancelNoShowReservationsJob < ApplicationJob
  queue_as :default

  def perform
    Reservation.reserved.where(start_time: ..15.minutes.ago).each do |reservation|
      ReservationMailer.reservation_cancelled(reservation).deliver_now
      reservation.destroy
    end
  end
end

# 予約の開始時間から15分経過してもチェックインされていない予約を自動キャンセルするためのジョブ。
