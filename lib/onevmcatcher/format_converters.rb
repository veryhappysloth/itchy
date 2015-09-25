# Wrapper for all available format converters.                                                                                                                                                          
module Onevmcatcher::FormatConverters; end 

# Load all available format converters
Dir.glob(File.join(File.dirname(__FILE__), 'format_converters', "*.rb")) { |handler_file| require handler_file.chomp('.rb') }
