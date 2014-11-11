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
      # TODO: do something
    end

    private

    # Runs basic check on the metadata directory.
    def init_metadata_dir!
      fail ArgumentError, 'Metadata directory is ' \
                          'not a directory!' unless File.directory? options.metadata_dir
      fail ArgumentError, 'Metadata directory is ' \
                          'not writable!' unless File.readable? options.metadata_dir
    end

  end
end
