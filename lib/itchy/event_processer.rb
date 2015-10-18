module Itchy

  class EventProcesser

    attr_reader :vmc_configuration, :options

    def initialize(vmc_configuration, options)
      fail ArgumentError, '"vmc_configuration" must be an instance ' \
        'of Itchy::VmcatcherConfiguration' unless vmc_configuration.kind_of? Itchy::VmcatcherConfiguration

      @vmc_configuration = vmc_configuration
      @options = options

    end

    def process!
      Itchy::Log.info "[#{self.class.name}] Processing eventes stored in #{options.metadata_dir}"
    
      archived_events do |event, event_file|
        begin
          event_handler = Itchy::EventHandlers.const_get("#{event.type}EventHandler")
          event_handler = event_handler.new(vmc_configuration, options)
          event_handler.handle!(event, event_file)

        #  clean_event!(event, event_file)
        end
      end
    end

    def archived_events(&block)
        arch_events = ::Dir.glob(::File.join(options.metadata_dir, '*.json'))
        arch_events.sort!
        Itchy::Log.debug "[#{self.class.name}] Foud events: #{arch_events.inspect}"
        arch_events.each do |json|
          json_short = json.split(::File::SEPARATOR).last

          unless Itchy::EventHandlers::BaseEventHandler::EVENT_FILE_REGEXP =~ json_short
            Itchy::Log.error "[#{self.class.name}] #{json.inspect} doesn't match the required format"
            next
          end

          vmc_event_from_json = read_event(json)
          block.call(vmc_event_from_json, json) if vmc_event_from_json
        end
    end

    def read_event(json)
      begin
        Itchy::VmcatcherEvent.new(::File.read(json))
      rescue => ex
        Itchy::Log.error "[]Failed to load event"
        return
      end
    end

    def clean_event!(event, event_file)
      Itchy::Log.info "[#{self.class.name}] Cleaning up"

      begin
        ::FileUtils.rm_f event_file
      rescue => ex
        Itchy::Log.fatal "Failed to clean up event"
      end
    end


    def check_descriptor_dir
      Itchy::Log.debug "[#{self.class.name}] Checking root descriptor dir #{options.descriptor_dir.inspect}"
      fail ArgumentError, 'Root descriptor directory' \
                          'is not a directory!' unless File.directory? options.descriptor_dir
      fail ArgumentError, 'Root descriptor directory' \
        'is not readable!' unless File.readable? opitons.descriptor_dir
    end


  end
end
