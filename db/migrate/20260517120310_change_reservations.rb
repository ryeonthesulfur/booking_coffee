class ChangeReservations < ActiveRecord::Migration[8.1]
  def change
    remove_column :reservations, :end_time, :datetime
    remove_column :reservations, :total_price, :integer
    remove_column :reservations, :status, :string
    add_column :reservations, :notes, :text
  end
end
