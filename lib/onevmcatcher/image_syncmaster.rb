module Onevmcatcher
  # Wraps image handling methods. All events previously
  # stored by Onevmcatcher::MetadataArchiver are processed
  # here. This is the place where actual image handling
  # happens.
  class ImageSyncmaster

    # Creates a Syncmaster instance handling stored
    # vmcatcher events.
    #
    # @param options [Hashie::Mash] options
    def initialize(options)
      @options = options || ::Hashie::Mash.new
    end

    # Triggers event synchronization on the metadata
    # directory specified in `options` provided to
    # the constructor.
    def sync!
      # TODO: do something
    end

  end
end
