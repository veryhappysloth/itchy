module Itchy
  # Wraps vmcatcher event handling methods. All events are
  # stored for subsequent processing. There is no actual image
  # handling happening here.
  class MetadataArchiver

    attr_reader :vmc_configuration, :options

    # Creates an archiver instance for storing vmcatcher
    # events to the file system for delayed processing.
    #
    # @param vmc_configuration [Itchy::VmcatcherConfiguration] vmcatcher configuration
    # @param options [Hashie::Mash] hash-like structure with options
    def initialize(vmc_configuration, options)
      fail ArgumentError, '"vmc_configuration" must be an instance ' \
           'of Itchy::VmcatcherConfiguration' unless vmc_configuration.kind_of? Itchy::VmcatcherConfiguration

      @vmc_configuration = vmc_configuration
      @options = options || ::Hashie::Mash.new

      init_metadata_dir!
    end

    # Triggers archiving of the provided event. Event is written
    # to the file system as a JSON-formatted document for delayed
    # processing.
    #
    # @param vmc_event [Itchy::VmcatcherEvent] event to store
    def archive!(vmc_event)
      fail ArgumentError, '"vmc_event" must be an instance ' \
           'of Itchy::VmcatcherEvent' unless vmc_event.kind_of? Itchy::VmcatcherEvent

      Itchy::Log.info "[#{self.class.name}] Archiving " \
                             "#{vmc_event.type.inspect} " \
                             "for #{vmc_event.dc_identifier.inspect}"

      begin
        event_handler = Itchy::EventHandlers.const_get("#{vmc_event.type}EventHandler")
      rescue NameError => ex
        fail Itchy::Errors::UnknownEventError,
             "Unknown event type #{vmc_event.type.inspect} detected: #{ex.message}"
      end

      event_handler = event_handler.new(vmc_configuration, options)
      event_handler.archive!(vmc_event)
    end

    private

    # Runs a basic check on the metadata directory.
    def init_metadata_dir!
      Itchy::Log.debug "[#{self.class.name}] Checking metadata directory #{options.metadata_dir.inspect}"

      fail ArgumentError, 'Metadata directory is ' \
                          'not a directory!' unless File.directory? options.metadata_dir
      fail ArgumentError, 'Metadata directory is ' \
                          'not writable!' unless File.writable? options.metadata_dir
    end

  end
end
