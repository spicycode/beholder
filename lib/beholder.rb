require 'rubygems'
require 'fsevents'

class Beholder
  DEFAULT_RUNNER = 'ruby'

  class << self
    attr_writer :runner, :test_types, :possible_treasure_map_locations
    
    def runner
      @runner ||= ::Beholder::DEFAULT_RUNNER
    end

    def possible_treasure_map_locations
      @possible_treasure_map_locations ||= ["#{Dir.pwd}/.treasure_map.rb", "#{Dir.pwd}/treasure_map.rb", "#{Dir.pwd}/config/treasure_map.rb"]
    end

    def test_types
      @test_types ||= %w{spec examples test}
    end

    def test_extensions
      @test_extensions ||= %w{spec example test}
    end

    def test_directories
      return @test_directories if @test_directories
      @test_directories = []
      test_types.each do |test_type|
        @test_directories << test_type if File.exist?(test_type) 
      end
      @test_directories
    end

    def all_tests
      lambda { 
        dirs = []
        test_directories.each do |dir|
          test_extensions.each do |test_ext|
            files = Dir["#{dir}/**/*_#{test_ext}.rb"]
            # Ignore tarantula tests for now until we add a cleaner way
            files.reject! { |file| file.include?('tarantula/') }
            next if files.empty?
            dirs << files
          end
        end
        dirs.flatten!
      }.call
    end
  end

  attr_reader :paths_to_watch, :sent_an_int, :mappings, :be_verbose
  attr_reader :watcher, :treasure_maps

  def initialize
    @paths_to_watch = []
    @mappings, @treasure_maps = {}, {}
    @sent_an_int = false
    @be_verbose = ARGV.include?("-v") || ARGV.include?("--verbose")
  end

  def run
    read_all_maps
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
    { :command => ::Beholder.runner }
  end

  def prepare_spell_for(pattern, options = {}, &blk)
    options = default_options.merge(options)
    @current_map << [pattern, options, blk]
  end

  def keep_a_watchful_eye_for(*paths)
    @paths_to_watch.concat(paths)
    @paths_to_watch.uniq!
    @paths_to_watch.sort!
  end

  alias :watch :keep_a_watchful_eye_for
  alias :add_mapping :prepare_spell_for

  def shutdown
    watcher.shutdown
    exit
  end

  def on_change(paths)
    say "#{paths} changed" unless paths.nil? || paths.empty?

    treasure_maps_changed = paths.select { |p| ::Beholder.possible_treasure_map_locations.include?(p) }
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

  def tests_matching(name)
    regex = %r%.*#{name}.*\.rb$%
    ::Beholder.all_tests.find_all { |ex| ex =~ regex }
  end

  def build_cmd(runner, paths)
    puts "\nRunning #{paths.join(', ').inspect} with #{runner}" 
    cmd = "#{runner} #{paths.join(' ')}"
    say cmd
    cmd
  end

  def read_all_maps
    read_default_map
    ::Beholder::possible_treasure_map_locations.each { |path| read_map_at(path) }
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
        run_tests ::Beholder.runner => ::Beholder.all_tests
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
    map_for(:and_lo_for_i_am_the_default_treasure_map) do |m|
      
      m.watch 'lib', *::Beholder.test_directories
      
      m.prepare_spell_for %r%lib/(.*)\.rb% do |match|
       tests_matching match[1] 
      end

      m.prepare_spell_for %r%.*#{::Beholder.test_extensions.join('|')}\.rb% do |match|
       tests_matching match[1] 
      end

    end
  end

  def clear_maps
    @treasure_maps = {}
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
        say "#{path} does not exist." unless found_treasure
      end
    end
    
    runners_with_paths.reject! { |runner, paths| paths.empty? }
  end
  
  def say(this_message_please)
    puts this_message_please if be_verbose
  end

end
