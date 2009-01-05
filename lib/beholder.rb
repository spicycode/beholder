require 'rubygems'
gem :fsevents
require 'fsevents'

class Beholder

  attr_reader :paths_to_watch, :sent_an_int, :mappings, :working_directory, :be_verbose, :the_eye
  
  def initialize
    @paths_to_watch = ['app', 'config', 'lib', 'examples']
    @sent_an_int = false
    @mappings = {}
    @working_directory = Dir.pwd
    @be_verbose = ARGV.include?("-v") || ARGV.include?("--verbose")
  end
  
  def self.cast_thy_gaze
    @beholder = new
    @beholder.prepare_for_interlopers    
    @beholder.open_your_eye
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
  
  def blink
    @sent_an_int = false
  end
  
  def close_your_eye
    the_eye.shutdown
    exit
  end
  
  def identify_stolen_treasure(treasure)
    say "Encountered file: #{treasure}"
    case treasure
    when /#{working_directory}\/app\/(.*)\.rb/
      "examples/#{$1}_example.rb"
    when /#{working_directory}\/lib\/(.*)\.rb/
      "examples/lib/#{$1}_example.rb"
    when /#{working_directory}\/examples\/(.*)_example\.rb/
      "examples/#{$1}_example.rb"
    when /#{working_directory}\/examples\/example_helper\.rb/,
         /#{working_directory}\/config/
      "examples/**/*_example.rb"
    else
      say "Unknown file: #{treasure}"
      ''
    end
  end

  def reclaim_stolen_treasure_at(coordinates)
    return if coordinates.nil? || coordinates.empty?
    puts "\nRunning #{coordinates.join(', ')}" 
    system "ruby #{coordinates.map { |f| Dir.glob(f) }.join(' ')}"
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