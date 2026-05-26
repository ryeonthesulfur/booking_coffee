class AddColumnsToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :end_time, :datetime
    add_column :reservations, :total_price, :integer
    add_column :reservations, :status, :integer, default: 0, null: false
  end
end


# 「end_time」、「total_price」は退店時に更新されるカラムで、予約の終了時間と合計金額を保存するため、null: falseは指定しませんでした。
# 理由は、ユーザーが予約後、退店するまで好きな時間だけいることができるようにするためです。
# 「status」は予約の状態を管理するためのカラムで、デフォルト値を0（予約中）に設定し、null: falseを指定して必ず値が入るようにしました。これにより、予約の状態を明確に管理できるようになります。
