require 'rubygems'
gem 'fsevents'
require 'fsevents'

class Beholder

  attr_reader :paths_to_watch, :sent_an_int, :mappings, :working_directory, :verbose
  attr_reader :watcher, :treasure_maps, :possible_map_locations, :all_examples, :default_runner

  def initialize
    @working_directory = Dir.pwd
    @paths_to_watch, @all_examples = [], []
    @mappings, @treasure_maps = {}, {}
    @sent_an_int = false
    @verbose = ARGV.include?("-v") || ARGV.include?("--verbose")
    @default_runner = 'ruby'
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
  
  def default_options
    { :command => "ruby" }
  end

  def add_mapping(pattern, options = {}, &blk)
    options = default_options.merge(options)
    @current_map << [pattern, options, blk]
  end

  def watch(*paths)
    @paths_to_watch.concat(paths)
    @paths_to_watch.uniq!
    @paths_to_watch.sort!
  end

  alias :keep_a_watchful_eye_for :watch
  alias :prepare_spell_for :add_mapping

  def shutdown
    watcher.shutdown
    exit
  end

  def on_change(paths)
    say "#{paths} changed" unless paths.nil? || paths.empty?

    treasure_maps_changed = paths.select { |p| possible_map_locations.include?(p) }
    treasure_maps_changed.each {|map_path| read_map_at(map_path) }

    runners_with_paths = {}
    paths.each do |path| 
      find_and_populate_matches(path, runners_with_paths) 
    end  

    runners_with_paths.each do |runner, paths| 
      paths.uniq!
      paths.compact!
    end

    run_tests runners_with_paths
  end

  def examples_matching(name, suffix = "example")
    regex = %r%.*#{name}_#{suffix}\.rb$%
    all_examples.find_all { |ex| ex =~ regex }
  end

  def build_cmd(runner, paths)
    puts "\nRunning #{paths.join(', ').inspect} with #{runner}" 
    cmd = "#{runner} #{paths.join(' ')}"
    say cmd
    cmd
  end

  def read_all_maps
    read_default_map
    possible_map_locations.each { |path| read_map_at(path) }
  end

  def read_map_at(path)
    return unless File.exist?(path)
    say "Found a map at #{path}"
    begin
      instance_eval(File.readlines(path).join("\n"))
    rescue Object => e
      puts "Exception caught trying to load map at #{path}"
      puts e
    end
  end

  protected

  def prepare
    trap 'INT' do
      if @sent_an_int then      
        puts "   A second INT?  Ok, I get the message.  Shutting down now."
        shutdown
      else
        puts "   Did you just send me an INT? Ugh.  I'll quit for real if you do it again."
        @sent_an_int = true
        Kernel.sleep 1.5
        run_tests default_runner => all_examples
      end
    end
  end    

  def start
    startup_msg
    @watcher = FSEvents::Stream.watch(paths_to_watch) do |event|
      on_change(event.modified_files)
      puts "\n\nWaiting for changes since #{Time.now}"
    end
    @watcher.run
  end

  def startup_msg
    puts %[Beholder has loaded - CTRL-C once to reset, twice to quit.]
    puts %[Watching the following paths: #{paths_to_watch.join(", ")}]
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

      m.add_mapping %r%lib/(.*)\.rb% do |match|
        examples_matching match[1]
      end

    end
  end

  def clear_maps
    @treasure_maps = {}
  end

  # TODO: These need to be lambdas to catch newly added files
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

  def find_and_populate_matches(path, runners_with_paths)
    treasure_maps.each do |name, map|
      map.each do |pattern, options, blk|
        run_using = options[:command]
        if match = path.match(pattern)
          say "Found the match for #{path} using the #{name} map "
          runners_with_paths[run_using] ||= []
          runners_with_paths[run_using].concat(blk.call(match))
          return
        end
      end
    end

    puts "Unknown file: #{path}"
  end
  
  def run_tests(runners_with_paths)
    remove_runners_with_no_valid_files_to_run(runners_with_paths)

    return if runners_with_paths.empty?

    runners_with_paths.each do |runner, paths|
      system build_cmd(runner, paths)
    end
    
    blink
  end

  private

  def remove_runners_with_no_valid_files_to_run(runners_with_paths)
    runners_with_paths.each do |runner, paths|
      paths.reject! do |path|
        found_treasure = File.exist?(path)
        puts "#{path} does not exist." unless found_treasure
      end
    end
    
    runners_with_paths.reject! { |runner, paths| paths.empty? }
  end
  
  def say(msg)
    puts msg if verbose
  end

end
