class DropLocations < ActiveRecord::Migration
  def self.up
    drop_table :locations
  end

  def self.down

  end
end
