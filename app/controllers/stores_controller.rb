class StoresController < ApplicationController
  def index
    @stores = Store.includes(:seats).all
  end

  def show
    @store = Store.find(params[:id])
    @seats = @store.seats.order(:seat_number)
  end
end
