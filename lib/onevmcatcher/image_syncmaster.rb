module Onevmcatcher
  # Wraps image handling methods. All events previously
  # stored by Onevmcatcher::MetadataArchiver are processed
  # here. This is the place where actual image handling
  # happens.
  class ImageSyncmaster

    def initialize(options)
      @options = options || ::Hashie::Mash.new
    end

    def sync!
      # TODO: do something
    end

  end
end
