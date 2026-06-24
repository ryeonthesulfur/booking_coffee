class RemoveEndTimeAndTotalPriceFromReservations < ActiveRecord::Migration[8.1]
  def change
    remove_column :reservations, :end_time, :datetime
    remove_column :reservations, :total_price, :integer
  end
end
