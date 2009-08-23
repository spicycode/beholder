begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "beholder"
    gem.summary = "An ancient beholder that watches your treasure, and deals with thiefs"
    gem.email = "chad@spicycode.com, rsanheim@gmail.com"
    gem.homepage = "http://github.com/rsanheim/beholder"
    gem.description = "beholder"
    gem.authors = "Chad Humphries, Rob Sanheim"
    gem.has_rdoc = true
    gem.extra_rdoc_files = ["README.md", "LICENSE"]
    gem.bindir = 'bin'
    gem.default_executable = 'beholder'
    gem.executables = ["beholder"]
    gem.require_path = 'lib'
    gem.files = %w(LICENSE README.md Rakefile) + Dir.glob("{lib,spec}/**/*")
    gem.add_dependency "fsevents"
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "yard"
    gem.add_development_dependency "rr", ">= 0.7.0"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

begin 
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new(:spec) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['spec/**/*_spec.rb']
    spec.spec_opts = ['-c', '-fn']
  end

  Spec::Rake::SpecTask.new(:rcov) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rcov = true
    spec.spec_opts = ['-c', '-fn']
  end

  task :spec => :check_dependencies

  task :default => :spec
rescue LoadError
  task :default do
    abort "Rspec is not available."
  end
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
