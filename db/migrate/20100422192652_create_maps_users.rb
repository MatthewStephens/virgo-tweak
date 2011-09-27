class CreateMapsUsers < ActiveRecord::Migration
  def self.up
    create_table :maps_users do |t|
      t.column :computing_id, :string
    end
  end

  def self.down
    drop_table :maps_users
  end
end