require File.expand_path(File.dirname(__FILE__) + "/../example_helper")

describe Beholder do

  describe "when run is called" do
    
    it "should create a new beholder" do
      beholder = stub(Beholder.new) { prepare; start }
      mock(Beholder).new { beholder }
      
      Beholder.run
    end
    
    it "should prepare" do
      beholder = Beholder.new 
      stub(beholder).start
      mock(beholder).prepare
      stub(Beholder).new { beholder }
      
      Beholder.run
    end
    
    it "should start" do
      beholder = Beholder.new 
      mock(beholder).start
      stub(beholder).prepare
      stub(Beholder).new { beholder }
      
      Beholder.run
    end
    
  end
  
  describe "when it notices file(s) changed" do
    
    it "should identify what was changed" do
      files = ['widgets'] 
      beholder = Beholder.new
      mock(beholder).find_matches('widgets') { nil }
      beholder.on_change files
    end
    
    it "should run tests for the file that changed" do
      files = ['widgets'] 
      beholder = Beholder.new
      stub(beholder).find_matches('widgets') { 'widgets_example' }
      mock(beholder).run_tests(['widgets_example'])
      beholder.on_change files
    end
    
    it "should match stuff" do
      files = ['widgets'] 
      beholder = Beholder.new
      stub(beholder).find_matches('widgets') { 'widgets_example' }
      mock(beholder).run_tests(['widgets_example'])
      beholder.on_change files
    end
  end
  
  describe "blink" do
    
    it "should forget about any interlopers" do
      beholder = Beholder.new
      beholder.instance_variable_set("@sent_an_int", true) # Not so hot, but I'm tired

      beholder.sent_an_int.should be_true
      beholder.blink
      beholder.sent_an_int.should be_false
    end
    
  end
  
  describe "when shutting down" do
    
    it "should stop watching for changes"  do
      beholder = Beholder.new
      stub(beholder).exit
      stub(beholder).watcher { mock!.shutdown }
      beholder.shutdown
    end
    
    it "should exit" do
      beholder = Beholder.new
      stub(beholder).watcher { stub!.shutdown }
      mock(beholder).exit
      beholder.shutdown
    end
    
  end
  
  describe "watch" do
    
    it "adds paths to watch" do
      beholder = Beholder.new
      beholder.watch "foo", "bar"
      beholder.paths_to_watch.should == ["foo", "bar"]
    end
    
    it "aliases keep_a_watchful_eye_for to watch" do
      beholder = Beholder.new
      beholder.keep_a_watchful_eye_for "foo", "bar"
      beholder.paths_to_watch.should == ["foo", "bar"]
    end
  end
  
end