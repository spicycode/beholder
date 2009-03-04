require 'rubygems'
gem :fsevents
require 'fsevents'

class Beholder

  attr_reader :paths_to_watch, :sent_an_int, :mappings, :working_directory, :verbose
  attr_reader :watcher, :treasure_maps, :possible_map_locations, :all_examples
  
  def initialize
    @working_directory = Dir.pwd
    @paths_to_watch, @all_examples = [], []
    @mappings, @treasure_maps = {}, {}
    @sent_an_int = false
    @verbose = ARGV.include?("-v") || ARGV.include?("--verbose")
    @possible_map_locations = ["#{@working_directory}/.treasure_map.rb", "#{@working_directory}/treasure_map.rb", "#{@working_directory}/config/treasure_map.rb"]
  end
  
  def run
    read_all_maps
    set_all_examples if all_examples.empty?
    prepare    
    start
  end
  
  def self.run
    beholder = new
    beholder.run
    self
  end
  
  def map_for(map_name)
    @treasure_maps[map_name] ||= []
    @current_map = @treasure_maps[map_name]
    yield self if block_given?
  ensure
    @current_map = nil
  end

  def add_mapping(pattern, &blk)
    @current_map << [pattern, blk]
  end

  def watch(*paths)
    @paths_to_watch.concat(paths)
  end
  
  alias :keep_a_watchful_eye_for :watch
  alias :prepare_spell_for :add_mapping

  def shutdown
    watcher.shutdown
    exit
  end

  def on_change(treasure)
    say "#{treasure} changed" unless treasure.empty?
    matches = treasure.map { |t| find_matches(t) }.uniq.compact
    run_tests matches
  end

  protected

  def read_all_maps
    read_default_map

    possible_map_locations.each do |map_location|
      if File.exist?(map_location)
        say "Found a map at #{map_location}"
        instance_eval(File.readlines(map_location).join("\n"))
        return
      end
    end
  end

  def prepare
    trap 'INT' do
      if @sent_an_int then      
        puts "   A second INT?  Ok, I get the message.  Shutting down now."
        shutdown
      else
        puts "   Did you just send me an INT? Ugh.  I'll quit for real if you do it again."
        @sent_an_int = true
        Kernel.sleep 1.5
        run_tests all_examples
      end
    end
  end    

  def start
    say("Watching the following locations:\n  #{paths_to_watch.join(", ")}")
    @watcher = FSEvents::Stream.watch(paths_to_watch) do |event|
      on_change(event.modified_files)
      puts "\n\nWaiting to hear from the disk since #{Time.now}"
    end
    @watcher.run
  end    
  
  def read_default_map
    map_for(:default) do |m|

      m.watch 'lib', 'examples'

      m.add_mapping %r%examples/(.*)_example\.rb% do |match|
        ["examples/#{match[1]}_example.rb"]
      end

      m.add_mapping %r%examples/example_helper\.rb% do |match|
        Dir["examples/**/*_example.rb"]
      end

      m.add_mapping %r%lib/(.*)\.rb% do |file|
        ["examples/lib/#{match[1]}_example.rb"]
      end

    end
  end

  def clear_maps
    @treasure_maps = {}
  end
  
  def set_all_examples
    if paths_to_watch.include?('examples')
      @all_examples += Dir['examples/**/*_example.rb']
    end
    
    if paths_to_watch.include?('test')
      @all_examples += Dir['test/**/*_test.rb']
    end
    
    if paths_to_watch.include?('spec')
      @all_examples += Dir['spec/**/*_spec.rb']
    end
  end

  def blink
    @sent_an_int = false
  end

  def find_matches(treasure)
    treasure_maps.each do |name, treasure_locations|
      treasure_locations.each do |stolen_by_enemy, spell| 
        if spell_components = treasure.match(stolen_by_enemy)
          say "Found the stolen treasure using the #{name} map "
          return spell.call(spell_components)
        end
      end
    end

    puts "Unknown file: #{treasure}"
    return []
  end

  def run_tests(coordinates)
    coordinates.flatten!

    coordinates.reject! do |coordinate|
      found_treasure = File.exist?(coordinate)
      puts "#{coordinate} does not exist." unless found_treasure
    end

    return if coordinates.empty?

    puts "\nRunning #{coordinates.join(', ').inspect}" 
    system "ruby #{coordinates.join(' ')}"
    blink
  end

  private
  def say(msg)
    puts msg if verbose
  end

end