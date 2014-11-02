# Wrapper for all available helpers.
module Onevmcatcher::Helpers; end

# Load all available helpers
Dir.glob(File.join(File.dirname(__FILE__), 'helpers', "*.rb")) { |helper_file| require helper_file.chomp('.rb') }
