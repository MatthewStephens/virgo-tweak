class AddNameToSpecialCollectionsRequests < ActiveRecord::Migration
  def self.up
    add_column :special_collections_requests, :name, :string
  end

  def self.down
    remove_column :special_collections_requests, :name
  end
end
