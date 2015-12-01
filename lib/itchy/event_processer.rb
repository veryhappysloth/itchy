module Itchy
  # Process stored evenets.
  class EventProcesser
    attr_reader :vmc_configuration, :options

    # Creates and processer instance for stored vmcatcher events.
    #
    # @param vmc_configuration [Itchy::Vmcatcher::Configuration] vmcatcher configuration
    # @param options [Hashie::Mash] hask-like structure with options
    def initialize(vmc_configuration, options)
      fail ArgumentError, '"vmc_configuration" must be an instance ' \
        'of Itchy::VmcatcherConfiguration' unless vmc_configuration.is_a? Itchy::VmcatcherConfiguration

      @vmc_configuration = vmc_configuration
      @options = options
    end

    # Processing method for events. For each event calls respective
    # event handler. And after processing of each event, stored event
    # file is deleted.
    def process!
      Itchy::Log.info "[#{self.class.name}] Processing eventes stored in #{options.metadata_dir}"

      archived_events do |event, event_file|
        begin
          
          begin
            event_handler = Itchy::EventHandlers.const_get("#{event.type}EventHandler")
            event_handler = event_handler.new(vmc_configuration, options)
            event_handler.handle!(event, event_file)
          rescue => Itchy::Errors::EventHandleError => ex
            Itchy::Log.error "[#{self.class.name}] Due to error #{ex.message} event #{event_file}" \
              "was not processed!!! Continuing with next stored event."
            next
          end

          begin
            clean_event!(event, event_file)
          rescue SystemCallError => ex
            Itchy::Log.error "[#{self.class.name}] Event #{event_file} was processed, but not cleaned!!!"
          end

        end
      end
    end

    # Prepares archived event for processing. That means inspect directory with
    # stored event files, and create VmcatcherEvent from each file.
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

    # Creates VmcatcherEvent instance.
    #
    # @param json json [String] path to file containing json representation
    # of vmcatcher event
    #
    # @return [VmcatcherEvent] instance representing event
    def read_event(json)
      Itchy::VmcatcherEvent.new(::File.read(json))
    rescue => ex
      Itchy::Log.error 'Failed to load event!!!'
      return ex
    end

    # Deletes event file.
    #
    # @param event [VmcatcherEvent] event for cleaning
    # @param event_file [String] path to file containing event info
    def clean_event!(_event, event_file)
      Itchy::Log.info "[#{self.class.name}] Cleaning up"

      begin
        ::FileUtils.rm_f event_file
      rescue SystemCallError => ex
        Itchy::Log.fatal 'Failed to clean up event!!!'
        return ex
      end
    end

    # Checks if description directory exists and its readable.
    def check_descriptor_dir
      Itchy::Log.debug "[#{self.class.name}] Checking root descriptor dir #{options.descriptor_dir.inspect}"
      fail ArgumentError, 'Root descriptor directory' \
                          'is not a directory!' unless File.directory? options.descriptor_dir
      fail ArgumentError, 'Root descriptor directory' \
        'is not readable!' unless File.readable? opitons.descriptor_dir
    end
  end
end
