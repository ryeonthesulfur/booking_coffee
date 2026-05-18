class StoresController < ApplicationController
  def index
    @stores = Store.includes(:seats).all
  end
end
