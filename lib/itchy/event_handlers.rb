# Wrapper for all available vmcatcher event handlers.
module Itchy::EventHandlers; end

# Load base handler first
require File.join(File.dirname(__FILE__), 'event_handlers', "base_event_handler")

# Load all available event handlers
Dir.glob(File.join(File.dirname(__FILE__), 'event_handlers', "*.rb")) { |handler_file| require handler_file.chomp('.rb') }
