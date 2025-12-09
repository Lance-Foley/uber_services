class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :job_request, null: false, foreign_key: true
      t.references :payer, null: false, foreign_key: { to_table: :users }
      t.references :payee, null: false, foreign_key: { to_table: :users }
      t.string :stripe_payment_intent_id
      t.string :stripe_charge_id
      t.string :stripe_transfer_id
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :platform_fee, precision: 10, scale: 2
      t.decimal :provider_amount, precision: 10, scale: 2
      t.string :currency, default: 'usd'
      t.string :status, default: 'pending'
      t.datetime :authorized_at
      t.datetime :captured_at
      t.datetime :released_at
      t.datetime :refunded_at
      t.text :failure_reason
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :payments, :stripe_payment_intent_id
    add_index :payments, :status
  end
end
