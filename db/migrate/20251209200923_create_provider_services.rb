class CreateProviderServices < ActiveRecord::Migration[8.0]
  def change
    create_table :provider_services do |t|
      t.references :provider_profile, null: false, foreign_key: true
      t.references :service_type, null: false, foreign_key: true
      t.integer :pricing_model
      t.decimal :base_price
      t.decimal :hourly_rate
      t.decimal :min_charge
      t.jsonb :size_pricing
      t.text :notes
      t.boolean :active

      t.timestamps
    end
  end
end
