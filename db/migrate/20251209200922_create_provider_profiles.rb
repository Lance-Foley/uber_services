class CreateProviderProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :provider_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name
      t.text :bio
      t.integer :service_radius_miles
      t.decimal :average_rating
      t.integer :total_reviews
      t.integer :completed_jobs
      t.boolean :verified
      t.boolean :accepting_jobs
      t.jsonb :availability_schedule
      t.string :stripe_account_id
      t.string :stripe_account_status
      t.boolean :stripe_charges_enabled
      t.boolean :stripe_payouts_enabled

      t.timestamps
    end
  end
end
