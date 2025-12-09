class CreateJobBids < ActiveRecord::Migration[8.0]
  def change
    create_table :job_bids do |t|
      t.references :job_request, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: { to_table: :users }
      t.decimal :bid_amount, precision: 8, scale: 2, null: false
      t.text :message
      t.datetime :estimated_arrival
      t.integer :estimated_duration_minutes
      t.string :status, default: 'pending'

      t.timestamps
    end

    add_index :job_bids, [:job_request_id, :provider_id], unique: true
  end
end
