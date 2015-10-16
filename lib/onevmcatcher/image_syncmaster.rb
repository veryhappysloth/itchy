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

      archived_events do |event_file, event|
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

      Onevmcatcher::Log.info "[#{self.class.name}] Synchronization from #{options.metadata_dir.inspect} finished"
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

    # Locates and reads archived events. Each event is given for
    # processing to the provided block. Events are processed in-order,
    # order is established in the underlying filesystem.
    #
    # @param block [Block] block processing archived events
    def archived_events(&block)
      arch_events = ::Dir.glob(::File.join(options.metadata_dir, '*.json'))
      arch_events.sort!

      Onevmcatcher::Log.debug "[#{self.class.name}] Found events: #{arch_events.inspect}"
      arch_events.each do |json|
        json_short = json.split(::File::SEPARATOR).last

        unless Onevmcatcher::EventHandlers::BaseEventHandler::EVENT_FILE_REGEXP =~ json_short
          Onevmcatcher::Log.error "[#{self.class.name}] #{json.inspect} doesn't match the required format"
          next
        end

        vmc_event_from_json = read_archived_event(json)
        block.call(json, vmc_event_from_json) if vmc_event_from_json
      end
    end

    # Reads the given JSON file and creates an event instance.
    #
    # @param json [String] path to json event file
    # @return [NilClass, Onevmcatcher::VmcatcherEvent] event instance or nil
    def read_archived_event(json)
      begin
        Onevmcatcher::VmcatcherEvent.new(::File.read(json))
      rescue => ex
        Onevmcatcher::Log.error "[#{self.class.name}] Failed to load event from #{json.inspect}: " \
                                "#{ex.message}"
        return
      end
    end

    # Cleans up after an event has been successfully processed.
    #
    # @param event_file [String] path to the event file
    # @param event [Onevmcatcher::VmcatcherEvent] event instance
    def clean_up_event!(event_file, event)
      Onevmcatcher::Log.info "[#{self.class.name}] Cleaning up #{event_file.inspect}"

      begin
        ::FileUtils.rm_f event_file
      rescue => ex
      Onevmcatcher::Log.fatal "[#{self.class.name}] Failed to clean up event " \
                                "#{event.type.inspect} from #{event_file.inspect}: " \
                                "#{ex.message}"
      end
    end

  end
end
