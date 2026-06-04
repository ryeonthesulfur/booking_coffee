class ReservationsController < ApplicationController
  def index
    @reservations = Reservation.where(user_id: current_user.id).includes(seat: :store)
    @user = current_user
  end
  def confirm
    @store = Store.find(params[:store_id])
    @seat = Seat.find(params[:seat_id])
    @reservation = Reservation.new(reservation_params)
    @reservation.user = current_user
    @reservation.seat = @seat
  end


  def create
    @store = Store.find(params[:store_id])
    @seat = Seat.find(params[:seat_id])
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      redirect_to complete_store_seat_reservation_path(@store, @seat, @reservation)
    else
      render "seats/show", status: :unprocessable_entity
    end
  end


  def complete
    @store = Store.find(params[:store_id])
    @seat = Seat.find(params[:seat_id])
    @reservation = Reservation.find(params[:id])
  end

  def show
    @reservation = Reservation.includes(seat: :store).find(params[:id])
    @store = @reservation.seat.store
    @seat = @reservation.seat
  end

  def destroy
    @reservation = Reservation.find(params[:id])
    if @reservation.user_id == current_user.id
      @reservation.destroy
      redirect_to reservations_path, notice: "予約をキャンセルしました。"
    else
      redirect_to reservations_path, alert: "予約のキャンセルに失敗しました。"
    end
  end


    private

  def reservation_params
    params.require(:reservation).permit(:start_time, :num_people, :phone_number, :notes).merge(user_id: current_user.id, seat_id: params[:seat_id])
  end
end



=begin

reservations_controller.rb
「seats#show」では、「/stores/:store_id/seats/:id(.:format) 」の「seats/:id」のidにはJSで「A-1」とかを入れて、
コントローラーでは、それに該当するseat_idをfind_byで見つけさせて入れてたけど、
それ以降はみつけさせたseat_id でデータを扱ってることになってるから、reservations コントローラーでは、seat_id でやらないといけない

=end
