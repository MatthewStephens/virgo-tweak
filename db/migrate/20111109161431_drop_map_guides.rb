class DropMapGuides < ActiveRecord::Migration
  def self.up
    drop_table :map_guides
  end

  def self.down
  end
end
