module Onevmcatcher
  # Wraps vmcatcher metadata taken from the environment.
  class VmcatcherEnv

    # Dummy keys
    REGISTERED_ENV_KEYS = [].freeze

    attr_reader :attributes

    # Creates an environment instance with pre-filtered
    # attributes.
    #
    # @param env [Object] hash-like object storing the raw environment
    def initialize(env)
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
      ::JSON.pretty_generate @attributes
    end

    # Generates an ordinary JSON document
    # from available ENV attributes.
    #
    # @return [String] JSON document
    def to_json
      ::JSON.generate @attributes
    end

  end
end
