module Onevmcatcher::EventHandlers
  # Basic handler implementing required methods. Can be used
  # as a dummy for testing purposes.
  class BaseEventHandler

    TEMPFILE_BASE = 'vmcatcher_event_metadata_archive'

    attr_reader :vmcatcher_configuration, :vmcatcher_event, :options

    # Event handler constructor.
    #
    # @param vmcatcher_event [Onevmcatcher::VmcatcherEvent] event being handled
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current vmcatcher configuration
    # @param options [Settingslogic] current onevmcatcher configuration
    def initialize(vmcatcher_event, vmcatcher_configuration, options)
      fail(
        ArgumentError,
        '\'vmcatcher_event\' must be an instance of Onevmcatcher::VmcatcherEvent!'
      ) unless vmcatcher_event.kind_of? Onevmcatcher::VmcatcherEvent

      fail(
        ArgumentError,
        '\'vmcatcher_configuration\' must be an instance of Onevmcatcher::VmcatcherConfiguration!'
      ) unless vmcatcher_configuration.kind_of? Onevmcatcher::VmcatcherConfiguration

      @vmcatcher_configuration = vmcatcher_configuration
      @vmcatcher_event = vmcatcher_event
      @options = options

      init_metadata_dir!
    end

    # Triggers an archiving procedure on the registered event.
    def archive!
      Onevmcatcher::Log.info "[#{self.class.name}] Saving " \
                             "#{vmcatcher_event.type.inspect} " \
                             "for #{vmcatcher_event.dc_identifier.inspect}"

      temp_file = ::Tempfile.new(TEMPFILE_BASE)
      permanent_file_path = ::File.join(
        options.metadata_dir,
        "#{vmcatcher_event.type || 'Unknown'}_#{vmcatcher_event.dc_identifier || 'NoID'}_#{::Time.now.to_i}.json"
      )

      temp_file.write(vmcatcher_event.to_pretty_json)
      temp_file.flush

      ::FileUtils.cp(temp_file.path, permanent_file_path)
      temp_file.close

      true
    end

    # Triggers a handling procedure on the registered event.
    def handle!
      # This has to be implemented in subclasses!
      fail Onevmcatcher::Errors::NotImplementedError, "Not implemented!"
    end

    protected

    # Runs basic check on the metadata directory.
    def init_metadata_dir!
      Onevmcatcher::Log.debug "[#{self.class.name}] Checking metadata directory #{options.metadata_dir.inspect}"

      fail ArgumentError, 'Metadata directory is ' \
                          'not a directory!' unless File.directory? options.metadata_dir
      fail ArgumentError, 'Metadata directory is ' \
                          'not writable!' unless File.writable? options.metadata_dir
    end

  end
end
