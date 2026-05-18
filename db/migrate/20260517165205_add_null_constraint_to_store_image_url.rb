class AddNullConstraintToStoreImageUrl < ActiveRecord::Migration[8.1]
  def change
    change_column_null :stores, :image_url, false
  end
end
