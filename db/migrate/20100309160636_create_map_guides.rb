class CreateMapGuides < ActiveRecord::Migration
  def self.up
    create_table :map_guides do |t|
      t.column :location_id, :integer
      t.column :map_id, :integer
      t.column :call_number_range, :string
    end
  end

  def self.down
    drop_table :map_guides
  end
end