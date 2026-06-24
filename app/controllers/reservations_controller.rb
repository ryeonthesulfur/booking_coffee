class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: [ :complete, :destroy ]
  def index
    @reservations = current_user.reservations.includes(seat: :store)
    @user = current_user
  end
  def confirm
    @store = Store.find(params[:store_id])
    @seat = Seat.find(params[:seat_id])
    @reservation = Reservation.new(reservation_params)

    start_time = @reservation.start_time

    # ユーザーが選択した時刻(start_time)に利用中となる予約を探す
    # 条件: 予約の開始時刻(S)が (start_time - 3時間) < S < (start_time + 3時間) の間にある
    @reserved_seat_numbers = @store.seats
      .joins(:reservations)
      .where(reservations: { status: [ :reserved, :using ] })
      .where("reservations.start_time > ? AND reservations.start_time < ?", start_time - 3.hours, start_time + 3.hours)
      .pluck(:seat_number)
  end

  def new
    @seat = Seat.find_by(seat_number: params[:seat_id], store_id: params[:store_id])
    @reservation = Reservation.new(params.permit(:start_time, :num_people, :phone_number, :notes))  # 予約内容修正の際、確認画面時点での情報をクエリパラメーターでそのまま渡すため。
    @store = Store.find(params[:store_id])
  end

  def create
    @store = Store.find(params[:store_id])
    @seat = Seat.find(params[:seat_id])
    @reservation = Reservation.new(reservation_params)
    @reservation.user = current_user
    @reservation.seat = @seat
    if @reservation.save
      redirect_to complete_store_seat_reservation_path(@store, @seat, @reservation)
    else
      render "reservations/new", status: :unprocessable_entity
    end
  end

  def complete
    @store = Store.find(params[:store_id])
    @seat = Seat.find(params[:seat_id])
  end

  def show
    @reservation = current_user.reservations.includes(seat: :store).find(params[:id])
    @store = @reservation.seat.store
    @seat = @reservation.seat
  end

  def destroy
    if @reservation.destroy
      redirect_to reservations_path, notice: "予約をキャンセルしました。"
    else
      redirect_to reservations_path, alert: "予約のキャンセルに失敗しました。"
    end
  end


  def check_in
    @reservation = current_user.reservations.find(params[:id])
    @reservation.update!(status: :using)
    redirect_to reservation_path(@reservation), notice: "チェックインしました。"
  end

    private

  def reservation_params
    params.require(:reservation).permit(:start_time, :num_people, :phone_number, :notes).merge(user_id: current_user.id, seat_id: params[:seat_id])
  end


  def set_reservation
    @reservation = current_user.reservations.find(params[:id])
  end
end

=begin

reservations_controller.rb
「seats#show」では、「/stores/:store_id/seats/:id(.:format) 」の「seats/:id」のidにはJSで「A-1」とかを入れて、
コントローラーでは、それに該当するseat_idをfind_byで見つけさせて入れてたけど、
それ以降はみつけさせたseat_id でデータを扱ってることになってるから、reservations コントローラーでは、seat_id でやらないといけない

=end


=begin

「A-1」の座席を選択したら、valueの「A-1」が「document.querySelector('input[name="seat_id"]:checked').value;」で取得されて、「${seatNumber}」に「A-1」が入るということ。

そしてそのURLがルーティングにいって、「resources :seats, only: [ :show ]」だから「shows コントローラー」に渡る。

「A-1」は、「window.location.href」の時点ですでに「/stores/:store_id/seats/:id(.:format)  」の「:id」というデータとして扱われている。

そして、seats コントローラーで、選択された座席の「A-1」はURIパターンとしての「:id」としてparamsに箱詰めされる。

だから厳密には、seat の bigint としての id ではない。


=end
