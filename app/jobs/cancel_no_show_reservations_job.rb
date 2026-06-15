class CancelNoShowReservationsJob < ApplicationJob
  queue_as :default

  def perform
    Reservation.reserved.where(start_time: ..15.minutes.ago).each do |reservation|
      ReservationMailer.reservation_cancelled(reservation).deliver_now
      reservation.destroy
    end
  end
end

# 予約の開始時間から15分経過してもチェックインされていない予約を自動キャンセルするジョブ。
# 予約の状態が「reserved」で、開始時間が現在時刻の15分前までのものを対象にする。
# 15分経過した予約に対して、予約キャンセルのメールをユーザーに送信し、その後予約を削除する。
# このジョブは、config/schedule.rb で毎分実行されるように設定されている。
