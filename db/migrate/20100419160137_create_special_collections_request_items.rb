class CreateSpecialCollectionsRequestItems < ActiveRecord::Migration
  def self.up
    create_table :special_collections_request_items do |t|
      t.column :special_collections_request_id, :string
      t.column :location, :string
      t.column :call_number, :string
    end
  end

  def self.down
    drop_table :special_collections_request_items
  end
end
