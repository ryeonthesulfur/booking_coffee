class AddPhoneNumberToReservations < ActiveRecord::Migration[8.1]
  def change
    add_column :reservations, :phone_number, :string, null: false
  end
end
