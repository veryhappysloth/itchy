# Load base handler first
require File.join(File.dirname(__FILE__), 'event_handlers', "base_event_handler")

# Load all available event handlers
Dir.glob(File.join(File.dirname(__FILE__), 'event_handlers', "*.rb")) { |event_file| require event_file.chomp('.rb') }
