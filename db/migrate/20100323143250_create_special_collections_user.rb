class CreateSpecialCollectionsUser < ActiveRecord::Migration
  def self.up
    create_table :special_collections_users do |t|
      t.column :computing_id, :string
    end
  end

  def self.down
    drop_table :special_collections_users
  end
end
