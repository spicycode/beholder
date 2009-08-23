require File.expand_path(File.dirname(__FILE__) + "/spec_helper")                                                

describe Beholder do

  describe "runner" do
    it "should be 'ruby'" do
      Beholder.runner.should == 'ruby'
    end
  end

  describe "test types" do
    it "should include 'spec', 'examples', and 'test' by default" do
      Beholder.test_types.should include('spec')
      Beholder.test_types.should include('examples')
      Beholder.test_types.should include('test')
    end
  end

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
      mock(beholder).find_and_populate_matches('widgets', {}) { nil }
      beholder.on_change files
    end
    
    it "should re-eval the treasure map if the map was modified" do
      treasure_map = "#{Dir.pwd}/.treasure_map.rb"
      beholder = Beholder.new
      stub(File).exist?(treasure_map) { true }
      mock(beholder).read_map_at(treasure_map)
      beholder.on_change treasure_map
    end
    
  end
  
  describe "build_cmd" do
    it "contructs build cmd for a single file" do
      beholder = Beholder.new
      beholder.build_cmd("ruby", ["test/foo_test.rb"]).should == "ruby test/foo_test.rb"
    end
    
    it "contructs build cmd for a multiple files" do
      beholder = Beholder.new
      beholder.build_cmd("ruby", ["test/foo_test.rb", "test/functionals/foo_test.rb"]).should == %[ruby test/foo_test.rb test/functionals/foo_test.rb]
    end
    
  end
  
  describe "blink" do
    
    it "should forget about any interlopers" do
      beholder = Beholder.new
      beholder.instance_variable_set("@sent_an_int", true) # Not so hot, but I'm tired

      beholder.sent_an_int.should be_true
      beholder.__send__ :blink
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
      beholder.watch "bar", "foo"
      beholder.paths_to_watch.should == ["bar", "foo"]
    end
    
    it "aliases keep_a_watchful_eye_for to watch" do
      beholder = Beholder.new
      beholder.keep_a_watchful_eye_for "bar", "foo"
      beholder.paths_to_watch.should == ["bar", "foo"]
    end
    
    it "should uniq and sort the paths" do
      beholder = Beholder.new
      beholder.watch "foo", "bar", "specs", "foo", "bar", "bar2"
      beholder.paths_to_watch.should == ["bar", "bar2", "foo", "specs"]
    end
  end
  
  describe "prepare spell for" do
    def generate_map(beholder, blk)
      beholder.map_for(:example) { |m| m.prepare_spell_for(%r%example_helper\.rb%, &blk) }
    end
    
    it "adds pattern and block to current_map" do
      beholder = Beholder.new
      blk = lambda { "something" }
      generate_map(beholder, blk)
      beholder.treasure_maps[:example].should == [[ %r%example_helper\.rb%, {:command => "ruby"}, blk ]]
    end
    
    # it "aliases prepare_spell_for to add_mapping" do
      # beholder = Beholder.new
      # blk = lambda { "something" }
      # generate_map(beholder, blk)
      # beholder.treasure_maps[:example].should == [[ %r%example_helper\.rb%, {:command => "ruby"}, blk ]]
    # end
    
    # it "adds mapping using default command of ruby" do
      # beholder = Beholder.new
      # blk = lambda { "something" }
      # generate_map(beholder, blk)
      # beholder.treasure_maps[:example].should == [[ %r%example_helper\.rb%, {:command => "ruby"}, blk ]]
    # end
  end
  
  describe "tests_matching" do

    it "finds a fuzzy match from all tests" do
      beholder = Beholder.new
      stub(Beholder).all_tests { ["spec/unit/bar_example.rb", "src/foo_system_example.rb", "spec/some/deeper/dir/foo_example.rb"] }
      beholder.tests_matching("foo").should == ["src/foo_system_example.rb", "spec/some/deeper/dir/foo_example.rb"]
    end
  end
  
  describe "read_map_at" do
    
    it "rescues exceptions from instance_eval'ing the map, and carries on" do
      beholder = Beholder.new
      stub(File).exist? { true }
      mock(File).readlines("my_map.rb") { ["!and this is invalid Ruby;end\nand more"] }
      stub(beholder).puts
      lambda { beholder.read_map_at("my_map.rb") }.should_not raise_error
    end
    
  end
  
  describe "say" do
    
    it "puts to stdout if verbose is true" do
      begin 
        ARGV.push("-v")
        beholder = Beholder.new
        mock(beholder).puts("yo dawg")
        beholder.__send__ :say, "yo dawg"
      ensure
        ARGV.pop
      end
    end
  end
  
end
