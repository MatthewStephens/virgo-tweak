require 'active_record/fixtures'

class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :code
	    t.string :value
    end
    ActiveRecord::Fixtures.create_fixtures('test/fixtures', 'locations')  
    end

  def self.down
    drop_table :locations
  end
end
