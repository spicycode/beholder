lib_path = File.expand_path(File.dirname(__FILE__) + "/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'beholder'
require 'rubygems'
require 'micronaut'
gem :rr, '=0.7.0'
require 'log_buddy'
LogBuddy.init

def not_in_editor?
  ['TM_MODE', 'EMACS', 'VIM'].all? { |k| !ENV.has_key?(k) }
end

Micronaut.configure do |c|
  c.formatter = :documentation
  c.mock_with :rr
  c.color_enabled = not_in_editor?  
  c.filter_run :focused => true
end