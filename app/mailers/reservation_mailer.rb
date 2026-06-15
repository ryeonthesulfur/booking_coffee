class ReservationMailer < ApplicationMailer
  def reservation_cancelled(reservation)
    @reservation = reservation
    @user = reservation.user
    mail(to: @user.email, subject: "【booking coffee】ご予約が自動キャンセルされました")
  end
end


=begin

このメソッドは、予約が自動キャンセルされたときにユーザーに通知するためのメールを送信するためのものです。
mail(to:, subject:) が「誰に」「件名は何」を指定する部分。

メールの内容は、app/views/reservation_mailer/reservation_cancelled.html.erb で定義されている。
予約が自動キャンセルされるのは、予約の開始時間から15分経過してもユーザーがチェックインしていない場合で、
その処理は app/jobs/reservation_auto_cancel_job.rb に記述されている。

=end
