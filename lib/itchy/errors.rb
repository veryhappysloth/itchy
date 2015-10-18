# Wrapper for all available errors.
module Itchy::Errors; end

# Load all available errors
Dir.glob(File.join(File.dirname(__FILE__), 'errors', "*.rb")) { |error_file| require error_file.chomp('.rb') }
