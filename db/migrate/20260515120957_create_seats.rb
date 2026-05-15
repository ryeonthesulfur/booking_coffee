class CreateSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :seats do |t|
      t.integer :seat_number, null: false
      t.integer :capacity, null: false
      t.integer :price_per_hour, null: false
      t.timestamps
    end
    add_index :seats, :seat_number, unique: true
  end
end
