class StoresController < ApplicationController
  before_action :authenticate_user!, except: [ :index, :show ]

  def index
    # 全店舗を座席情報と一緒に取得
    @stores = Store.includes(:seats).all
  end

  def show
    # URLのidから店舗を取得
    @store = Store.find(params[:id])

    # 座席番号順に座席一覧を取得
    @seats = @store.seats.order(:seat_number)

    if params[:start_time].present?
      start_time = Time.zone.parse(params[:start_time].delete("〜"))

      # ユーザーが選択した時刻(start_time)に利用中となる予約を探す
      # 条件: 予約の開始時刻(S)が (start_time - 3時間) < S <= start_time の間にある
      @reserved_seat_numbers = @store.seats
        .joins(:reservations)
        .where(reservations: { status: [ :reserved, :using ] })
        .where("reservations.start_time > ? AND reservations.start_time <= ?", start_time - 3.hours, start_time)
        .pluck(:seat_number)
    else
      # 日時未選択のとき：次の30分スロットを基準にグレイアウト計算する
      now = Time.zone.now
      default_time = now.min < 30 ? now.change(min: 30, sec: 0) : now.change(hour: now.hour + 1, min: 0, sec: 0)
      @reserved_seat_numbers = @store.seats
        .joins(:reservations)
        .where(reservations: { status: [ :reserved, :using ] })
        .where("reservations.start_time > ? AND reservations.start_time <= ?", default_time - 3.hours, default_time)
        .pluck(:seat_number)
    end

    # 座席タイプごとの席数を集計（店舗詳細画面のサマリー表示用）
    @seats_summary = @store.seats.group(:seat_type).count
  end
end
