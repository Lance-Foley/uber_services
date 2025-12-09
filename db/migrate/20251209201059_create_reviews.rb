class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :job_request, null: false, foreign_key: true
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :reviewee, null: false, foreign_key: { to_table: :users }
      t.integer :rating, null: false
      t.text :comment
      t.text :response
      t.datetime :responded_at
      t.boolean :visible, default: true
      t.boolean :flagged, default: false

      t.timestamps
    end

    add_index :reviews, [:job_request_id, :reviewer_id], unique: true
    add_index :reviews, [:reviewee_id, :rating]
  end
end
