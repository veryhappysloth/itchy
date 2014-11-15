module Onevmcatcher
  # Wraps vmcatcher metadata taken from the environment.
  class VmcatcherEnv

    # Dummy keys
    REGISTERED_ENV_KEYS = [].freeze

    attr_reader :attributes

    # Creates an environment instance with pre-filtered
    # attributes.
    #
    # @param env [Object] hash-like or JSON-like object storing the raw environment
    def initialize(env)
      env = ::JSON.parse(env) if env.kind_of?(String)

      @attributes = Onevmcatcher::Helpers::VmcatcherEnvHelper.select_from_env(
        env,
        self.class::REGISTERED_ENV_KEYS
      )
    end

    # Generates a human-readable JSON document
    # from available ENV attributes.
    #
    # @return [String] pretty JSON document
    def to_pretty_json
      ::JSON.pretty_generate attributes
    end

    # Generates an ordinary JSON document
    # from available ENV attributes.
    #
    # @return [String] JSON document
    def to_json
      ::JSON.generate attributes
    end

    # Converts event attributes into a hash-like
    # structure.
    #
    # @return [Hashie::Mash] hash-like structure with metadata
    def to_hash
      attr_converted = ::Hashie::Mash.new
      attributes.each_pair { |name, val| attr_converted[name.downcase] = val }
      attr_converted
    end

    class << self

      # Creates an instance from a JSON document.
      #
      # @param json [String] JSON to create an instance from
      # @return [Onevmcatcher::VmcatcherEnv] instance
      def from_json(json)
        self.new ::JSON.parse(json)
      end

    end

  end
end
