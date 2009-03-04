# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{beholder}
  s.version = "0.5.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chad Humphries, Rob Sanheim"]
  s.date = %q{2009-03-03}
  s.default_executable = %q{beholder}
  s.description = %q{beholder}
  s.email = %q{chad@spicycode.com, rsanheim@gmail.com}
  s.executables = ["beholder"]
  s.extra_rdoc_files = ["README.textile", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README.textile", "Rakefile", "TODO", "lib/beholder.rb", "examples/example_helper.rb", "examples/lib", "examples/lib/beholder_example.rb", "bin/beholder"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/rsanheim/beholder}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{An ancient beholder that watches your treasure, and deals with thiefs}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fsevents>, [">= 0"])
    else
      s.add_dependency(%q<fsevents>, [">= 0"])
    end
  else
    s.add_dependency(%q<fsevents>, [">= 0"])
  end
end
