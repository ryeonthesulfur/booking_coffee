class RemoveSaleColumnsFromSeats < ActiveRecord::Migration[8.1]
  def change
    remove_column :seats, :is_sale, :boolean
    remove_column :seats, :sale_price_per_hour, :integer
  end
end
