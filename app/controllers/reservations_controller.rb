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

    unless @reservation.valid?
      render "reservations/new", status: :unprocessable_entity and return
    end

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
