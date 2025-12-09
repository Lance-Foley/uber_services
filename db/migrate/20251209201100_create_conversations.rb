class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :job_request, null: true, foreign_key: true
      t.references :participant_one, null: false, foreign_key: { to_table: :users }
      t.references :participant_two, null: false, foreign_key: { to_table: :users }
      t.datetime :last_message_at
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :conversations, [:participant_one_id, :participant_two_id], unique: true
  end
end
