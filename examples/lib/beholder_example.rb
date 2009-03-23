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
    
  end
  
  describe "build_cmd" do
    it "contructs build cmd for a single file" do
      beholder = Beholder.new
      beholder.build_cmd(["test/foo_test.rb"]).should == %[ruby -e "%w[test/foo_test].each { |f| require f }"]
    end
    
    it "contructs build cmd for a multiple files" do
      beholder = Beholder.new
      beholder.build_cmd(["test/foo_test.rb", "test/functionals/foo_test.rb"]).should == %[ruby -e "%w[test/foo_test test/functionals/foo_test].each { |f| require f }"]
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
  
  describe "add_mapping" do
    
    it "adds pattern and block to current_map" do
      beholder = Beholder.new
      blk = lambda { "something" }
      beholder.map_for(:example) { |m| m.add_mapping(%r%example_helper\.rb%, &blk) }
      beholder.treasure_maps[:example].should == [[ %r%example_helper\.rb%, blk ]]
    end
    
    it "aliases prepare_spell_for to add_mapping" do
      beholder = Beholder.new
      blk = lambda { "something" }
      beholder.map_for(:example) { |m| m.prepare_spell_for(%r%example_helper\.rb%, &blk) }
      beholder.treasure_maps[:example].should == [[ %r%example_helper\.rb%, blk ]]
    end
  end
  
  describe "examples_matching" do

    it "finds a fuzzy match from all_examples" do
      beholder = Beholder.new
      stub(beholder).all_examples { ["examples/unit/foo_example.rb", "examples/slow/foo_example.rb", "src/foo_system_example.rb", "examples/some/deeper/dir/foo_example.rb"] }
      beholder.examples_matching("foo").should == ["examples/unit/foo_example.rb", "examples/slow/foo_example.rb", "examples/some/deeper/dir/foo_example.rb"]
    end
  end
  
  describe "output" do
    
    it "say puts to stdout if verbose is true" do
      begin 
        ARGV.push("-v")
        beholder = Beholder.new
        mock(beholder).puts("yo dawg")
        beholder.send :say, "yo dawg"
      ensure
        ARGV.pop
      end
    end
  end
  
end