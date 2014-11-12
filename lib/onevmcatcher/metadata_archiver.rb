module Onevmcatcher
  # Wraps vmcatcher event handling methods. All events are
  # stored for subsequent processing. There is no actual image
  # handling happening here.
  class MetadataArchiver

    attr_reader :vmc_event, :vmc_configuration, :options

    # Creates an archiver instance for storing vmcatcher
    # events to the file system for delayed processing.
    #
    # @param vmc_event [Onevmcatcher::VmcatcherEvent] event to store
    # @param vmc_configuration [Onevmcatcher::VmcatcherConfiguration] vmcatcher configuration
    # @param options [Hashie::Mash] hash-like structure with options
    def initialize(vmc_event, vmc_configuration, options)
      fail ArgumentError, '"vmc_event" must be an instance ' \
           'of Onevmcatcher::VmcatcherEvent' unless vmc_event.kind_of? Onevmcatcher::VmcatcherEvent
      fail ArgumentError, '"vmc_configuration" must be an instance ' \
           'of Onevmcatcher::VmcatcherConfiguration' unless vmc_configuration.kind_of? Onevmcatcher::VmcatcherConfiguration

      @vmc_event = vmc_event
      @vmc_configuration = vmc_configuration
      @options = options || ::Hashie::Mash.new
    end

    # Triggers archiving of the provided event. Event is written
    # to the file system as a JSON-formatted document for delayed
    # processing.
    def archive!
      Onevmcatcher::Log.info "[#{self.class.name}] Archiving " \
                             "#{vmc_event.type.inspect} " \
                             "for #{vmc_event.dc_identifier.inspect}"

      begin
        event_handler = Onevmcatcher::EventHandlers.const_get("#{vmc_event.type}EventHandler")
      rescue NameError => ex
        fail Onevmcatcher::Errors::UnknownEventError,
             "Unknown event type #{vmc_event.type.inspect} detected: #{ex.message}"
      end

      event_handler = event_handler.new(vmc_event, vmc_configuration, options)
      event_handler.archive!
    end

  end
end
