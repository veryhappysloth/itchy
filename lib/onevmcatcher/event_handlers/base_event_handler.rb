module Onevmcatcher::EventHandlers
  # Basic handler implementing required methods. Can be used
  # as a dummy for testing purposes.
  class BaseEventHandler

    TEMPFILE_BASE = 'vmcatcher_event_metadata_archive'
    EVENT_FILE_REGEXP = /^(?<time>\d+)_(?<type>[[:alnum:]]+)_(?<dc_identifier>[[[:alnum:]]-]+)\.json$/

    attr_reader :vmcatcher_configuration, :options

    # Event handler constructor.
    #
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current vmcatcher configuration
    # @param options [Settingslogic] current onevmcatcher configuration
    def initialize(vmcatcher_configuration, options)
      unless vmcatcher_configuration.kind_of?(Onevmcatcher::VmcatcherConfiguration)
        fail ArgumentError, '\'vmcatcher_configuration\' must be an instance of ' \
                            'Onevmcatcher::VmcatcherConfiguration!'
      end

      @vmcatcher_configuration = vmcatcher_configuration
      @options = options || ::Hashie::Mash.new
    end

    # Triggers an archiving procedure on the registered event.
    #
    # @param vmcatcher_event [Onevmcatcher::VmcatcherEvent] event being archived
    def archive!(vmcatcher_event)
      unless vmcatcher_event.kind_of?(Onevmcatcher::VmcatcherEvent)
        fail ArgumentError, '\'vmcatcher_event\' must be an instance of ' \
                            'Onevmcatcher::VmcatcherEvent!'
      end

      Onevmcatcher::Log.info "[#{self.class.name}] Saving " \
                             "#{vmcatcher_event.type.inspect} " \
                             "for #{vmcatcher_event.dc_identifier.inspect}"

      temp_file = ::Tempfile.new(TEMPFILE_BASE)
      permanent_file_path = ::File.join(
        options.metadata_dir,
        "#{::Time.now.to_i}_#{vmcatcher_event.type || 'Unknown'}_#{vmcatcher_event.dc_identifier || 'NoID'}.json"
      )

      temp_file.write(vmcatcher_event.to_pretty_json)
      temp_file.flush

      ::FileUtils.cp(temp_file.path, permanent_file_path)
      temp_file.close

      true
    end

    # Triggers a handling procedure on the registered event.
    #
    # @param vmcatcher_event [Onevmcatcher::VmcatcherEvent] event being handled
    def handle!(vmcatcher_event)
      unless vmcatcher_event.kind_of?(Onevmcatcher::VmcatcherEvent)
        fail ArgumentError, '\'vmcatcher_event\' must be an instance of ' \
                            'Onevmcatcher::VmcatcherEvent!'
      end

      Onevmcatcher::Log.warn "[#{self.class.name}] Processing event " \
                             "#{vmcatcher_event.type.inspect} for " \
                             "#{vmcatcher_event.dc_identifier.inspect}"
    end

    protected

    # Creates a datastore instance from options.
    #
    # @return [BaseDatastoreConnector] datastore instance
    def datastore_instance
      @datastore_instance_cache ||= options.datastore.new(options)
    end

    # Creates an image transformer instance with options.
    #
    # @return [ImageTransformer] image transformer instance
    def image_transformer_instance
      @image_transformer_instance_cache ||= Onevmcatcher::ImageTransformer.new(options)
    end

  end
end
