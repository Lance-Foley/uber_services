class CreateServiceCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :service_categories do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :icon_name
      t.boolean :active
      t.integer :position

      t.timestamps
    end
    add_index :service_categories, :slug, unique: true
  end
end
