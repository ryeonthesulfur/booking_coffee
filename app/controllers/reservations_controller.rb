class ReservationsController < ApplicationController
  def confirm
    @store = Store.find(params[:store_id])
    @seat = Seat.find(params[:seat_id])
    @reservation = Reservation.new(reservation_params)
    @reservation.user = current_user
    @reservation.seat = @seat
  end


    private

  def reservation_params
    params.require(:reservation).permit(:start_time, :num_people, :phone_number, :notes)
  end
end



=begin

reservations_controller.rb
「seats#show」では、「/stores/:store_id/seats/:id(.:format) 」の「seats/:id」のidにはJSで「A-1」とかを入れて、
コントローラーでは、それに該当するseat_idをfind_byで見つけさせて入れてたけど、
それ以降はみつけさせたseat_id でデータを扱ってることになってるから、reservations コントローラーでは、seat_id でやらないといけない

=end
