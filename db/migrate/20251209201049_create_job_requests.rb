class CreateJobRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :job_requests do |t|
      t.references :consumer, null: false, foreign_key: { to_table: :users }
      t.references :provider, null: true, foreign_key: { to_table: :users }
      t.references :property, null: false, foreign_key: true
      t.references :service_type, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.datetime :requested_date, null: false
      t.datetime :requested_time_start
      t.datetime :requested_time_end
      t.boolean :flexible_timing, default: false
      t.integer :urgency, default: 0
      t.string :status, default: 'pending', null: false
      t.decimal :estimated_price, precision: 8, scale: 2
      t.decimal :final_price, precision: 8, scale: 2
      t.decimal :platform_fee, precision: 8, scale: 2
      t.decimal :provider_payout, precision: 8, scale: 2
      t.decimal :platform_fee_percentage, precision: 5, scale: 2, default: 15.0
      t.datetime :accepted_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :cancelled_at
      t.string :cancellation_reason
      t.references :cancelled_by, null: true, foreign_key: { to_table: :users }
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :job_requests, :status
    add_index :job_requests, :requested_date
    add_index :job_requests, [:consumer_id, :status]
    add_index :job_requests, [:provider_id, :status]
  end
end
