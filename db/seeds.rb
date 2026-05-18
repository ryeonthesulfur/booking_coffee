# 既存データを全削除（外部キー制約があるので reservations → seats → stores の順）
Reservation.destroy_all
Seat.destroy_all
Store.destroy_all

# ── 店舗データ ──────────────────────────────────────────────────────
# name: 店舗名, image_url: 画像URL, smoking: 喫煙可かどうか
stores_data = [
  {
    name: "カフェ・ロンド",
    image_url: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=2070&auto=format&fit=crop",
    smoking: true
  },
  {
    name: "蔵前喫茶店",
    image_url: "https://images.unsplash.com/photo-1445116572660-236099ec97a0?q=80&w=2070&auto=format&fit=crop",
    smoking: false
  },
  {
    name: "喫茶むすび",
    image_url: "https://images.unsplash.com/photo-1442512595331-e89e73853f31?q=80&w=2070&auto=format&fit=crop",
    smoking: false
  }
]

stores_data.each do |data|
  Store.create!(data)
end

puts "#{Store.count}店舗のシードが完了しました"

# ── 席データ ────────────────────────────────────────────────────────
# 店舗名をキーにして、その店舗の席一覧をまとめたハッシュ
# seat_number: 席番号（A=カウンター, B=テーブル, C=テラス）
# capacity: 最大人数, price_per_hour: 1時間あたりの料金（円）
seats_by_store = {
  "カフェ・ロンド" => [
    { seat_number: "A-1", seat_type: "カウンター席", capacity: 1, price_per_hour: 500 },
    { seat_number: "A-2", seat_type: "カウンター席", capacity: 1, price_per_hour: 500 },
    { seat_number: "A-3", seat_type: "カウンター席", capacity: 1, price_per_hour: 500 },
    { seat_number: "A-4", seat_type: "カウンター席", capacity: 1, price_per_hour: 500 },
    { seat_number: "A-5", seat_type: "カウンター席", capacity: 1, price_per_hour: 500 },
    { seat_number: "B-1", seat_type: "テーブル席",   capacity: 2, price_per_hour: 800 },
    { seat_number: "B-2", seat_type: "テーブル席",   capacity: 4, price_per_hour: 1100 },
    { seat_number: "B-3", seat_type: "テーブル席",   capacity: 2, price_per_hour: 800 },
    { seat_number: "B-4", seat_type: "テーブル席",   capacity: 4, price_per_hour: 1100 },
    { seat_number: "C-1", seat_type: "テラス席",     capacity: 2, price_per_hour: 900 },
    { seat_number: "C-2", seat_type: "テラス席",     capacity: 4, price_per_hour: 1300 },
  ],
  "蔵前喫茶店" => [
    { seat_number: "A-1", seat_type: "カウンター席", capacity: 1, price_per_hour: 550 },
    { seat_number: "A-2", seat_type: "カウンター席", capacity: 1, price_per_hour: 550 },
    { seat_number: "A-3", seat_type: "カウンター席", capacity: 1, price_per_hour: 550 },
    { seat_number: "A-4", seat_type: "カウンター席", capacity: 1, price_per_hour: 550 },
    { seat_number: "A-5", seat_type: "カウンター席", capacity: 1, price_per_hour: 550 },
    { seat_number: "A-6", seat_type: "カウンター席", capacity: 1, price_per_hour: 550 },
    { seat_number: "A-7", seat_type: "カウンター席", capacity: 1, price_per_hour: 550 },
    { seat_number: "B-1", seat_type: "テーブル席",   capacity: 2, price_per_hour: 850 },
    { seat_number: "B-2", seat_type: "テーブル席",   capacity: 4, price_per_hour: 1200 },
    { seat_number: "B-3", seat_type: "テーブル席",   capacity: 2, price_per_hour: 850 },
  ],
  "喫茶むすび" => [
    { seat_number: "B-1", seat_type: "テーブル席", capacity: 2, price_per_hour: 750 },
    { seat_number: "B-2", seat_type: "テーブル席", capacity: 4, price_per_hour: 1050 },
    { seat_number: "B-3", seat_type: "テーブル席", capacity: 2, price_per_hour: 750 },
    { seat_number: "B-4", seat_type: "テーブル席", capacity: 4, price_per_hour: 1050 },
    { seat_number: "B-5", seat_type: "テーブル席", capacity: 2, price_per_hour: 750 },
    { seat_number: "B-6", seat_type: "テーブル席", capacity: 4, price_per_hour: 1050 },
    { seat_number: "C-1", seat_type: "テラス席",   capacity: 2, price_per_hour: 850 },
    { seat_number: "C-2", seat_type: "テラス席",   capacity: 2, price_per_hour: 850 },
    { seat_number: "C-3", seat_type: "テラス席",   capacity: 4, price_per_hour: 1150 },
  ]
}

# 店舗名でDBから店舗を取得し、その店舗に紐づけて席を作成
seats_by_store.each do |store_name, seats_data|
  store = Store.find_by!(name: store_name)
  seats_data.each do |data|
    store.seats.create!(data)
  end
end

puts "#{Seat.count}席のシードが完了しました"

# ── create! のイメージ ───────────────────────────────────────────────
# store.seats.create!(data) が実行されるたびに、
# seats テーブルに 1行 追加される。
#
# id | store_id | seat_number | seat_type    | capacity | price_per_hour
# ---|----------|-------------|--------------|----------|---------------
#  1 |    1     |    A-1      | カウンター席  |    1     |     500
#  2 |    1     |    A-2      | カウンター席  |    1     |     500
#  3 |    1     |    B-1      | テーブル席    |    2     |     800
#  4 |    2     |    A-1      | カウンター席  |    1     |     550  ← 蔵前喫茶店の席
#
# seeds.rb を実行すると、この表に 30行分のデータが一気に追加される。
