module Onevmcatcher
  # Wraps image handling methods. All events previously
  # stored by Onevmcatcher::MetadataArchiver are processed
  # here. This is the place where actual image handling
  # happens.
  class ImageSyncmaster

    attr_reader :options

    # Creates a Syncmaster instance handling stored
    # vmcatcher events.
    #
    # @param options [Hashie::Mash] options
    def initialize(options)
      @options = options || ::Hashie::Mash.new
      init_metadata_dir!
    end

    # Triggers event synchronization on the metadata
    # directory specified in `options` provided to
    # the constructor.
    def sync!
      Onevmcatcher::Log.info "[#{self.class.name}] Synchronizing events from #{options.metadata_dir.inspect}"
      # TODO: do something
      #
      # find_archived_event_files.each do |event_file|
      #   begin
      #     read_file event_file
      #     locate_event_handler
      #     instantiate_handler
      #     run_handler with_event
      #   rescue NameError => nex
      #     log_missing_handler
      #   rescue => ex
      #     log_stuff # we have to continue
      #   end
      #
      #   remove_event_file
      # end
      #
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

  end
end
