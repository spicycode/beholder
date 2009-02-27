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
  
  describe "when it notices a thief taking treasure" do
    
    it "should identify what was stolen" do
      treasures = ['pot_o_gold'] 
      beholder = Beholder.new
      mock(beholder).identify_stolen_treasure('pot_o_gold') { nil }
      beholder.notice_thief_taking treasures
    end
    
    it "should reclaim the stolen treasures" do
      treasures = ['pot_o_gold'] 
      beholder = Beholder.new
      stub(beholder).identify_stolen_treasure('pot_o_gold') { 'x marks the spot' }
      mock(beholder).run_tests(['x marks the spot'])
      beholder.notice_thief_taking treasures
    end
    
  end
  
  describe "when blinking it's eye" do
    
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
  
end