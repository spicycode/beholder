begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "beholder"
    s.summary = "An ancient beholder that watches your treasure, and deals with thiefs"
    s.email = "chad@spicycode.com, rsanheim@gmail.com"
    s.homepage = "http://github.com/rsanheim/beholder"
    s.description = "beholder"
    s.authors = "Chad Humphries, Rob Sanheim"
    s.has_rdoc = true
    s.extra_rdoc_files = ["README.textile", "LICENSE", 'TODO']
    s.add_dependency "fsevents"
    s.bindir = 'bin'
    s.default_executable = 'beholder'
    s.executables = ["beholder"]
    s.require_path = 'lib'
    s.files = %w(LICENSE README.textile Rakefile TODO) + Dir.glob("{lib,examples}/**/*")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

begin
  gem "spicycode-micronaut"
  require 'micronaut/rake_task'

  desc "Run all micronaut examples"
  Micronaut::RakeTask.new :examples do |t|
    t.pattern = "examples/**/*_example.rb"
  end

  namespace :examples do
    desc "Run all micronaut examples using rcov"
    Micronaut::RakeTask.new :coverage do |t|
      t.pattern = "examples/**/*_example.rb"
      t.rcov = true
      t.rcov_opts = "--exclude \"examples/*,gems/*,db/*,/Library/Frameworks/*,/Library/Ruby/*,config/*\" --text-summary  --sort coverage " 
    end
  end

  task :default => 'examples:coverage'
rescue LoadError
  puts "Micronaut required to run examples. Install it with: sudo gem install spicycode-micronaut -s http://gems.github.com"
end
