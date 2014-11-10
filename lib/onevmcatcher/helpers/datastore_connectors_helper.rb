require 'onevmcatcher/datastore_connectors'

module Onevmcatcher::Helpers
  # Wraps static helper methods for accessing information
  # about loaded datastore connectors.
  module DatastoreConnectorsHelper

    # Derives names of available datastores from class names of
    # available connectors.
    #
    # @return [Array] a list of available datastore names
    def self.datastores
      available_connectors = Onevmcatcher::DatastoreConnectors.constants.map { |conn| conn.to_s }
      available_connectors.select! { |conn| conn.end_with?('DatastoreConnector') && conn != 'BaseDatastoreConnector' }
      available_connectors.map! { |conn| conn.gsub('DatastoreConnector', '').downcase }

      available_connectors
    end

    # Converts a datastore name into the corresponding datastore
    # connector class.
    #
    # @param datastore_name [String] name of the datastore
    # @return [Class] class of the datastore connector
    def self.datastore_connector(datastore_name)
      Onevmcatcher::DatastoreConnectors.const_get("#{datastore_name.capitalize}DatastoreConnector")
    end

  end
end
