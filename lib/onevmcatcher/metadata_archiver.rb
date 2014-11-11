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

      init_metadata_dir!
    end

    # Triggers archiving of the provided event. Event is written
    # to the file system as a JSON-formatted document for delayed
    # processing.
    def archive!
      temp_file = ::Tempfile.new('vmcatcher_event_metadata_archive')
      permanent_file_path = ::File.join(
        options.metadata_dir,
        "#{vmc_event.type || 'Unknown'}_#{vmc_event.dc_identifier || 'NoID'}_#{::Time.now.to_i}.json"
      )

      temp_file.write vmc_event.to_pretty_json
      temp_file.flush

      ::FileUtils.cp temp_file.path, permanent_file_path
      temp_file.close
    end

    private

    # Runs basic check on the metadata directory.
    def init_metadata_dir!
      fail ArgumentError, 'Metadata directory is ' \
                          'not a directory!' unless File.directory? options.metadata_dir
      fail ArgumentError, 'Metadata directory is ' \
                          'not writable!' unless File.writable? options.metadata_dir
    end

  end
end
