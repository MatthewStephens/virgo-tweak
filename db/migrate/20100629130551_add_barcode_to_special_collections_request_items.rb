class AddBarcodeToSpecialCollectionsRequestItems < ActiveRecord::Migration
  def self.up
    add_column :special_collections_request_items, :barcode, :string
    
  end

  def self.down
    remove_column :special_collections_request_items, :barcode
  end
  
end
