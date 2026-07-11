class ReservationMailer < ApplicationMailer
  def reservation_cancelled(reservation)
    @reservation = reservation
    @user = reservation.user
    mail(to: @user.email, subject: "【booking coffee】ご予約が自動キャンセルされました")
  end
end
