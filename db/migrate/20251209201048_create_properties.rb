class CreateProperties < ActiveRecord::Migration[8.0]
  def change
    create_table :properties do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.decimal :latitude
      t.decimal :longitude
      t.integer :property_size
      t.decimal :lot_size_sqft
      t.decimal :driveway_length_ft
      t.text :special_instructions
      t.jsonb :photos
      t.boolean :primary
      t.boolean :active

      t.timestamps
    end
  end
end
