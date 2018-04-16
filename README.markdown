# Beholder

An ancient beholder that watches your treasure, and deals with thiefs.

## What does it do?

Think autotest, but powered by fseventd.

## Requirements

* OSX 10.5 or higher
* RubyCocoa
* fsevents gem

The default treasure map:

    map_for(:default_dungeon) do |wizard|
      
      wizard.keep_a_watchful_eye_for 'app', 'config', 'lib', 'examples'
     
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


In your own treasure map (stored as treasure_map.rb, .treasure_map.rb, or config/treasure_map.rb) you could do:

    map_for(:beholders_lair) do |wizard|
      
      # Clear all watched paths => wizard.paths_to_watch.clear
      # Add these paths to the paths to watch
      wizard.keep_a_watchful_eye_for 'coverage'
      
      # Forget all other treasure maps loaded
      # wizard.clear_maps
     
      # Add your own rules
      # wizard.prepare_spell_for /\/foobar/ do
      #   Dir["examples/foobar/*_example.rb"]
      # end

      # You could set the list of all examples to be run after pressing ctrl-c once
      # it defaults to any files in examples, spec, and test
      wizard.all_examples = Dir['your/path/**/*_here.rb']
    end

Treasure maps are automatically reloaded when you change them, so you can fire up Beholder and start iterating on the config live.
