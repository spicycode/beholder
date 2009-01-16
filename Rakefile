require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require 'micronaut/rake_task'

GEM = "beholder"
GEM_VERSION = "0.5.3"
AUTHOR = "Chad Humphries"
EMAIL = "chad@spicycode.com"
HOMEPAGE = "http://github.com/spicycode/beholder"
SUMMARY = "An ancient beholder that watches your treasure, and deals with thiefs"

spec = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.textile", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.add_dependency "fsevents"
  s.bindir = 'bin'
  s.default_executable = 'beholder'
  s.executables = ["beholder"]
  s.require_path = 'lib'
  s.autorequire = GEM
  s.files = %w(LICENSE README.textile Rakefile TODO) + Dir.glob("{lib,examples}/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_gemspec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "Run all micronaut examples"
Micronaut::RakeTask.new :examples do |t|
  t.pattern = "examples/**/*_example.rb"
end

namespace :examples do
  
  desc "Run all micronaut examples using rcov"
  Micronaut::RakeTask.new :coverage do |t|
    t.pattern = "examples/**/*_example.rb"
    t.rcov = true
    t.rcov_opts = "--exclude \"examples/*,gems/*,db/*,/Library/Frameworks/*,/Library/Ruby/*,config/*\" --text-summary  --sort coverage --no-validator-links" 
  end

end

task :default => 'examples:coverage'