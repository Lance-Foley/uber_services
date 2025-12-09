class CreateServiceTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :service_types do |t|
      t.references :service_category, null: false, foreign_key: true
      t.string :name
      t.string :slug
      t.text :description
      t.string :icon_name
      t.boolean :active
      t.integer :position
      t.decimal :suggested_min_price
      t.decimal :suggested_max_price

      t.timestamps
    end
    add_index :service_types, :slug, unique: true
  end
end
