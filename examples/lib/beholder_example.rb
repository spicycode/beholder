require File.expand_path(File.dirname(__FILE__) + "/../example_helper")

describe Beholder do

  describe "when casting it's gaze" do
    
    it "should begat a new beholder" do
      beholder = stub(Beholder.new) { prepare_for_interlopers; open_your_eye; spawn_dragon }
      mock(Beholder).new { beholder }
      
      Beholder.cast_thy_gaze
    end
    
    it "should prepare the child for interlopers" do
      beholder = Beholder.new 
      stub(beholder).open_your_eye
      stub(beholder).spawn_dragon
      mock(beholder).prepare_for_interlopers
      stub(Beholder).new { beholder }
      
      Beholder.cast_thy_gaze
    end
    
    it "should open the child's eyes" do
      beholder = Beholder.new 
      mock(beholder).open_your_eye
      stub(beholder).spawn_dragon
      stub(beholder).prepare_for_interlopers
      stub(Beholder).new { beholder }
      
      Beholder.cast_thy_gaze
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
      mock(beholder).reclaim_stolen_treasure_at(['x marks the spot'])
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
  
  describe "when closing it's eye" do
    
    it "should stop watching for interlopers"  do
      beholder = Beholder.new
      stub(beholder).exit
      stub(beholder).the_eye { mock!.shutdown }
      beholder.close_your_eye
    end
    
    it "should leave the dungeon" do
      beholder = Beholder.new
      stub(beholder).the_eye { stub!.shutdown }
      mock(beholder).exit
      beholder.close_your_eye
    end
    
  end
  
end