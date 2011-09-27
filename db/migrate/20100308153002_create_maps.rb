class CreateMaps < ActiveRecord::Migration
  def self.up
    create_table :maps do |t|
	    t.string :url
	    t.string :description
    end
  end

  def self.down
    drop_table :maps
  end
end
