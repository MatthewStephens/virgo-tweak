require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require "rake"

describe "cover_images:delete_old_requests" do

  before do
    @rake = Rake::Application.new      
    Rake.application = @rake
    Rake.application.rake_require "lib/tasks/cover_images"
    Rake::Task.define_task(:environment)
    @task_name = "cover_images:delete_old_requests"
  end
  
  it "should call DocumentImageRequestRecord.delete_old_requests" do
    days_old = 1
    DocumentImageRequestRecord.should_receive(:delete_old_requests).with(days_old)  
    @rake[@task_name].invoke(days_old)
  end
    
end

