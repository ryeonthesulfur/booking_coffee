class SeatsController < ApplicationController
  before_action :authenticate_user!, only: [ :show ]
  def show
    @seat = Seat.find_by(seat_number: params[:id], store_id: params[:store_id])
    @reservation = Reservation.new
    @store = Store.find(params[:store_id])
  end
end



=begin

「A-1」の座席を選択したら、valueの「A-1」が「document.querySelector('input[name="seat_id"]:checked').value;」で取得されて、「${seatNumber}」に「A-1」が入るということ。

そしてそのURLがルーティングにいって、「resources :seats, only: [ :show ]」だから「shows コントローラー」に渡る。

「A-1」は、「window.location.href」の時点ですでに「/stores/:store_id/seats/:id(.:format)  」の「:id」というデータとして扱われている。

そして、seats コントローラーで、選択された座席の「A-1」はURIパターンとしての「:id」としてparamsに箱詰めされる。

だから厳密には、seat の bigint としての id ではない。


=end
