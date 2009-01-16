require 'rubygems'
gem :fsevents
require 'fsevents'

class Proc
  alias :cast! :call
end

class Beholder

  attr_reader :paths_to_watch, :sent_an_int, :mappings, :working_directory, :be_verbose, :the_eye, :treasure_maps
  
  def initialize
    @paths_to_watch = ['app', 'config', 'lib', 'examples', 'test', 'spec']
    @sent_an_int = false
    @mappings = {}
    @working_directory = Dir.pwd
    @be_verbose = ARGV.include?("-v") || ARGV.include?("--verbose")
    @treasure_maps = {}
  end
  
  def self.cast_thy_gaze
    beholder = new
    beholder.read_all_the_maps
    beholder.prepare_for_interlopers    
    beholder.open_your_eye
  end
    
  def open_your_eye
    say("Watching the following locations:\n  #{paths_to_watch.join(", ")}")
    @the_eye = FSEvents::Stream.watch(paths_to_watch) do |treasure_chest|
      notice_thief_taking(treasure_chest.modified_files)
      blink
      puts "\n\nWaiting to hear from the disk since #{Time.now}"
    end
    @the_eye.run
  end    
  
  def map_for(map_name)
    @treasure_maps[map_name] ||= []
    @current_map = @treasure_maps[map_name]
    yield self if block_given?
    @current_map = nil
  end
  
  def prepare_spell_for(arcane_enemy, &spell)
    @current_map << [arcane_enemy, spell]
  end
  
  def cast_feeble_mind
    @paths_to_watch.clear
  end
  
  def keep_a_watchful_eye_for(*paths)
    @paths_to_watch.concat(paths)
  end
  
  def read_all_the_maps
    map_for(:default_dungeon) do |wizard|
      
      wizard.cast_feeble_mind
      wizard.keep_a_watchful_eye_for 'poodles', 'coverage'
     
      wizard.prepare_spell_for /\/app\/(.*)\.rb/ do |spell_component|
        ["examples/#{spell_component[1]}.rb"]
      end
      
      wizard.prepare_spell_for /\/lib\/(.*)\.rb/ do |spell_component|
        ["examples/lib/#{spell_component[1]}_example.rb"]
      end
      
      wizard.prepare_spell_for /\/examples\/(.*)_example\.rb/ do |spell_component|
        ["examples/#{spell_component[1]}_example.rb"]
      end
      
      wizard.prepare_spell_for /\/examples\/example_helper\.rb/ do |spell_component|
        Dir["examples/**/*_example.rb"]
      end
    
      wizard.prepare_spell_for /\/config/ do
        Dir["examples/**/*_example.rb"]
      end

    end
  end
  
  def blink
    @sent_an_int = false
  end
  
  def close_your_eye
    the_eye.shutdown
    exit
  end
  
  def identify_stolen_treasure(treasure)
    treasure_maps.each do |name, treasure_locations|
      treasure_locations.each do |stolen_by_enemy, spell| 
        if spell_components = treasure.match(stolen_by_enemy)
          return spell.cast!(spell_components)
        end
      end
    end
    
    puts "Unknown file: #{treasure}"
    return []
  end

  def reclaim_stolen_treasure_at(coordinates)
    coordinates.flatten!

    coordinates.reject! do |coordinate|
      not_there = !File.exist?(coordinate)
      puts "Example #{coordinate} does not actually exist." if not_there
      not_there
    end
    
    return if coordinates.empty?
    
    puts "\nRunning #{coordinates.join(', ').inspect}" 
    system "ruby #{coordinates.join(' ')}"
  end

  def notice_thief_taking(treasure)
    say "#{treasure} changed"
    coordinates = treasure.map { |t| identify_stolen_treasure(t) }.uniq.compact
    reclaim_stolen_treasure_at coordinates
  end
  
  def prepare_for_interlopers
    trap 'INT' do
      if @sent_an_int then      
        puts "   A second INT?  Ok, I get the message.  Shutting down now."
        close_your_eye
      else
        puts "   Did you just send me an INT? Ugh.  I'll quit for real if you do it again."
        @sent_an_int = true
        Kernel.sleep 1.5
      end
    end
  end
    
  private
  def say(this_message_please)
    puts this_message_please if be_verbose
  end
  
end