# Wrapper for all available datastore connectors.
module Onevmcatcher::DatastoreConnectors; end

# Load base datastore connector first
require File.join(File.dirname(__FILE__), 'datastore_connectors', "base_datastore_connector")

# Load all available datastore connectors
Dir.glob(File.join(File.dirname(__FILE__), 'datastore_connectors', "*.rb")) { |connector_file| require connector_file.chomp('.rb') }
