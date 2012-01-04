class AddDocumentIdIndexToDocumentImageRequestRecords < ActiveRecord::Migration
  def self.up
    add_index :document_image_request_records, :document_id
  end

  def self.down
    remove_index :document_image_request_records, :document_id
  end
end
