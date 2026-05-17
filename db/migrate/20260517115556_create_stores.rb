class CreateStores < ActiveRecord::Migration[8.1]
  def change
    create_table :stores do |t|
      t.string :name, null: false
      t.string :image_url, null: false
      t.boolean :smoking, null: false, default: false

      t.timestamps
    end
  end
end
