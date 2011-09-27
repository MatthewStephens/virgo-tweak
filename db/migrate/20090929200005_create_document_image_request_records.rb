class CreateDocumentImageRequestRecords < ActiveRecord::Migration
  def self.up
    create_table :document_image_request_records do |t|
      t.column :document_id, :string, :null => false
      t.column :requested_at, :timestamp, :null => false
    end
  end

  def self.down
    drop_table :document_image_request_records
  end
end
