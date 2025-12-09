class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :notification_type
      t.string :title
      t.text :body
      t.string :action_url
      t.jsonb :data
      t.boolean :read
      t.datetime :read_at
      t.boolean :push_sent
      t.datetime :push_sent_at

      t.timestamps
    end
  end
end
