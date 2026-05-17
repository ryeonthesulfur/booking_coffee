class ChangeSeats < ActiveRecord::Migration[8.1]
  def change
    remove_index :seats, :seat_number
    change_column :seats, :seat_number, :string, null: false
    add_reference :seats, :store, null: false, foreign_key: true
    add_column :seats, :seat_type, :string, null: false
  end
end
