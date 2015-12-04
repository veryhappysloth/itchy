# Wrapper for all available errors.
module Itchy::Errors; end

require File.join(File.dirname(__FILE__), 'errors', 'event_processing_error')
require File.join(File.dirname(__FILE__), 'errors', 'image_transformation_error')
# Load all available errors
Dir.glob(File.join(File.dirname(__FILE__), 'errors', '*.rb')) { |error_file| require error_file.chomp('.rb') }
