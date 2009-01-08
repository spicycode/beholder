require 'lib/beholder'

def enter_the_dungeon_of(dungeon_name)
  yield Beholder.cast_thy_gaze if block_given?
end

def keep_a_watchful_eye_for(*suspicous_things)
  Beholder.cast_watchful_eye_on.paths_to_watch.concat suspicous_things
end

def prepare_spell_for(monster_as_regex)
  Beholder.cast_thy_gaze
end

enter_the_dungeon_of('rails') do |wizard|
  
  wizard.keep_a_watchful_eye_for 'app', 'config', 'lib', 'test', 'spec', 'examples'
  
  wizard.prepare_spell_for /\/app\/(.*)\.rb/ do
    cast "examples/#{$1}.rb"
  end 
  
  wizard.prepare_spell_for /\/lib\/(.*)\.rb/ do
    cast "examples/lib/#{$1}.rb"
  end
  
  wizard.prepare_spell_for /\/examples\/(.*)_example\.rb/ do
   cast "examples/#{$1}_example.rb"
  end
  
  wizard.prepare_spell_for /\/examples\/example_helper\.rb/ do
   cast "examples/**/*_example.rb"
  end
  
  wizard.prepare_spell_for /\/config/ do
   cast "examples/**/*_example.rb"
  end
  
  wizard.protect_against_the_unknown do |unknown_element|
    say "Could not anticipate #{unknown_element}"
    cast "examples/**/*_example.rb"
  end
  
  wizard.spell_failed do
    retry_spell
  end
  
end