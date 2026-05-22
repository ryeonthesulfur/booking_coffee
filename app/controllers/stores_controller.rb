class StoresController < ApplicationController
  def index
    # 全店舗を座席情報と一緒に取得
    @stores = Store.includes(:seats).all
  end

  def show
    # URLのidから店舗を取得
    @store = Store.find(params[:id])
    # 座席番号順に座席一覧を取得
    @seats = @store.seats.order(:seat_number)
    # 座席タイプごとの席数を集計（店舗詳細画面のサマリー表示用）
    @seats_summary = @store.seats.group(:seat_type).count
  end
end
