module Itchy::EventHandlers
  # Basic handler implementing required methods. Can be used
  # as a dummy for testing purposes.
  class BaseEventHandler
    TEMPFILE_BASE = 'vmcatcher_event_metadata_archive'
    EVENT_FILE_REGEXP = /^(?<time>\d+)_(?<type>[[:alnum:]]+)_(?<dc_identifier>[[[:alnum:]]-]+)\.json$/

    attr_reader :vmcatcher_configuration, :options

    # Event handler constructor.
    #
    # @param vmcatcher_configuration [Itchy::VmcatcherConfiguration] current vmcatcher configuration
    # @param options [Settingslogic] current itchy configuration
    def initialize(vmcatcher_configuration, options)
      unless vmcatcher_configuration.is_a?(Itchy::VmcatcherConfiguration)
        fail ArgumentError, '\'vmcatcher_configuration\' must be an instance of ' \
                            'Itchy::VmcatcherConfiguration!'
      end

      @vmcatcher_configuration = vmcatcher_configuration
      @options = options || ::Hashie::Mash.new
    end

    # Triggers an archiving procedure on the registered event.
    #
    # @param vmcatcher_event [Itchy::VmcatcherEvent] event being archived
    def archive!(vmcatcher_event)
      unless vmcatcher_event.is_a?(Itchy::VmcatcherEvent)
        fail ArgumentError, '\'vmcatcher_event\' must be an instance of ' \
                            'Itchy::VmcatcherEvent!'
      end

      Itchy::Log.info "[#{self.class.name}] Saving " \
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
      set_file_permissions(permanent_file_path)
      temp_file.close

      true
    end

    # Handling procedure
    def handle!(vmcatcher_event, _event_file)
      unless vmcatcher_event.is_a?(Itchy::VmcatcherEvent)
        fail ArgumentError, '\'vmcatcher_event\' must be an instance of ' \
                'Itchy::VmcatcherEvent!'
      end
    end

    # Save created descriptor to descriptor directory.
    #
    # @param descriptor [String] json form of appliance descriptor
    # @param name [String] name of appliance descriptor (event name)
    def save_descriptor(descriptor, name)
      begin
        File.open("#{@options.descriptor_dir}/#{File.basename(name)}", 'w') { |f| f.write(descriptor) }
      rescue SystemCallError => ex
        Itchy::Log.fatal "[#{self.class.name}] Failed to save a descriptor #{File.basename(name)}. " \
          "Attempt failed with error #{ex.message}"
          fail Itchy::Errors::PrepareEnvError, ex
      end
      # file permissions for descriptor
      set_file_permissions(File.join(@options.descriptor_dir, File.basename(name)))
    end

    def set_file_permissions(file)
      Itchy::Log.debug "[#{self.class.name}] Setting file permissions for file #{file} to #{@options.file_permissions}."

      begin
        ::FileUtils.chmod @options.file_permissions.to_i(8), file
      rescue SystemCallError => ex
        Itchy::Log.error 'Failed to set permissions!!!'
        fail Itchy::Errors::PrepareEnvError, ex
      end
    end

    protected

    # Creates an image transformer instance with options.
    #
    # @return [ImageTransformer] image transformer instance
    def image_transformer_instance
      @image_transformer_instance_cache ||= Itchy::ImageTransformer.new(options)
    end
  end
end
