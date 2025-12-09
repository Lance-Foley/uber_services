class CreateDeviceTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :device_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token
      t.string :platform
      t.string :device_id
      t.boolean :active

      t.timestamps
    end
  end
end
