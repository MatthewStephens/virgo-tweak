class AddProcessedAtToSpecialCollectionsRequests < ActiveRecord::Migration
  def self.up
      add_column :special_collections_requests, :processed_at, :datetime
  end

  def self.down
      remove_column :special_collections_requests, :processed_at
  end
end
