module Onevmcatcher
  # Wraps image handling methods. All events previously
  # stored by Onevmcatcher::MetadataArchiver are processed
  # here. This is the place where actual image handling
  # happens.
  class ImageSyncmaster

    attr_reader :options, :vmc_configuration

    # Creates a Syncmaster instance handling stored
    # vmcatcher events.
    #
    # @param options [Hashie::Mash] options
    def initialize(vmc_configuration, options)
      fail ArgumentError, '"vmc_configuration" must be an instance ' \
           'of Onevmcatcher::VmcatcherConfiguration' unless vmc_configuration.kind_of? Onevmcatcher::VmcatcherConfiguration

      @vmc_configuration = vmc_configuration
      @options = options || ::Hashie::Mash.new

      init_metadata_dir!
    end

    # Triggers event synchronization on the metadata
    # directory specified in `options` provided to
    # the constructor.
    def sync!
      Onevmcatcher::Log.info "[#{self.class.name}] Synchronizing events from #{options.metadata_dir.inspect}"

      find_archived_events.each_pair do |event_file, event|
        begin
          event_handler = Onevmcatcher::EventHandlers.const_get("#{event.type}EventHandler")
          event_handler = event_handler.new(vmc_configuration, options)
          event_handler.handle!(event)

          clean_up_event!(event_file, event)
        rescue NameError => nex
          Onevmcatcher::Log.error "[#{self.class.name}] Missing event handler for #{event.type.inspect}"
        rescue => ex
          Onevmcatcher::Log.error "[#{self.class.name}] Synchronization for #{event.type.inspect} " \
                                  "from #{event_file.inspect} failed: #{ex.message}"
        end
      end
    end

    private

    # Runs basic check on the metadata directory.
    def init_metadata_dir!
      Onevmcatcher::Log.debug "[#{self.class.name}] Checking metadata directory #{options.metadata_dir.inspect}"

      fail ArgumentError, 'Metadata directory is ' \
                          'not a directory!' unless File.directory? options.metadata_dir
      fail ArgumentError, 'Metadata directory is ' \
                          'not readable!' unless File.readable? options.metadata_dir
    end

    # Locates and reads archived events. Provides a hash-like structure
    # where absolute paths are pointing to event instances.
    #
    # @return [Hash] JSON documents with events
    def find_archived_events
      events = {}

      ::Dir.glob(::File.join(options.metadata_dir, '*.json')) do |json|
        json_short = json.split(::File::SEPARATOR).last

        unless Onevmcatcher::EventHandlers::BaseEventHandler::EVENT_FILE_REGEXP =~ json_short
          Onevmcatcher::Log.error "[#{self.class.name}] #{json.inspect} doesn't match the required format"
          next
        end

        begin
          events[json] = Onevmcatcher::VmcatcherEvent.new(json)
        rescue => ex
          Onevmcatcher::Log.error "[#{self.class.name}] Failed to load event from #{json.inspect}"
        end
      end

      events
    end

    # Cleans up after an event has been successfully processed.
    #
    # @param event_file [String] path to the event file
    # @param event [Onevmcatcher::VmcatcherEvent] event instance
    def clean_up_event!(event_file, event)
      begin
        ::FileUtil.rm_f event_file
      rescue => ex
        Onevmcatcher::Log.fatal "[#{self.class.name}] Failed to clean up event " \
                                "#{event.type.inspect} from #{event_file.inspect}: " \
                                "#{ex.message}"
      end
    end

  end
end
