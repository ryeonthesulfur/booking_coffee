class AddSaleColumnsToSeats < ActiveRecord::Migration[8.1]
  def change
    add_column :seats, :is_sale, :boolean, null: false, default: false
    add_column :seats, :sale_price_per_hour, :integer
  end
end
