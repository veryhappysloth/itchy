# Wrapper for all available format transformers.                                                                                                                                                          
module Onevmcatcher::FormatTransformers; end 

# Load all available format transformers
Dir.glob(File.join(File.dirname(__FILE__), 'format_transformers', "*.rb")) { |handler_file| require handler_file.chomp('.rb') }
