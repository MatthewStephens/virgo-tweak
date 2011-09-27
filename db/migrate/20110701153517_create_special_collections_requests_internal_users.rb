class CreateSpecialCollectionsRequestsInternalUsers < ActiveRecord::Migration
  def self.up
    create_table :special_collections_requests_internal_users do |t|
      t.column :computing_id, :string
  end

  def self.down
    drop_table :special_collections_requests_internal_users
  end
  end
end
