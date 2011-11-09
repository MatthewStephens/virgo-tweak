class AddLibraryToMaps < ActiveRecord::Migration
  def self.up
    add_column :maps, :library_id, :integer
  end

  def self.down
    remove_column :maps, :library_id
  end
end
