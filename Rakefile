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
    gem.add_dependency "fsevents", ">= 0.1.1"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "rr", ">= 0.7.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
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

  task :default => [:check_dependencies, :spec]
rescue LoadError
  task :default do
    abort "Rspec is not available."
  end
end

begin
  %w{sdoc sdoc-helpers rdiscount}.each { |name| gem name }
  require 'sdoc_helpers'
rescue LoadError => ex
  puts "sdoc support not enabled:"
  puts ex.inspect
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "beholder #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

