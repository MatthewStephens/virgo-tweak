require 'active_record/fixtures'

class CreateLocations < ActiveRecord::Migration
  def self.up
    drop_table :locations
  end

  def self.down

  end
end
