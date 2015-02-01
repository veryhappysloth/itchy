module Onevmcatcher::DatastoreConnectors
  # Basic connector implementing required methods. Can be used
  # as a dummy for testing purposes.
  class BaseDatastoreConnector

    attr_reader :options

    def initialize(options)
      @options = options || ::Hashie::Mash.new
    end

    # Disables/removes an existing image.
    #
    # @param metadata [Onevmcatcher::VmcatcherEvent] image information
    def expire_image!(metadata); end

    # Uploads/registers new image to the datastore.
    #
    # @param metadata [Onevmcatcher::VmcatcherEvent] image information
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current VMC configuration
    def register_image!(metadata, vmcatcher_configuration); end

  end
end
