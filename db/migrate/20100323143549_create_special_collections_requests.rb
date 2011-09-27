class CreateSpecialCollectionsRequests < ActiveRecord::Migration
  def self.up
    create_table :special_collections_requests do |t|
      t.column :user_id, :string
      t.column :document_id, :string
      t.column :user_note, :text
      t.column :staff_note, :text
      t.column :created_at, :timestamp
    end
  end

  def self.down
    drop_table :special_collections_requests
  end
end
