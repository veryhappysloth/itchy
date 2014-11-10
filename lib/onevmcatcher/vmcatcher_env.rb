module Onevmcatcher
  # Wraps vmcatcher meta data.
  class VmcatcherEnv

    # Dummy keys
    REGISTERED_ENV_KEYS = [].freeze

    attr_reader :attributes

    def initialize(env)
      @attributes = Onevmcatcher::Helpers::VmcatcherEnvHelper.select_from_env(
        env,
        self.class::REGISTERED_ENV_KEYS
      )
    end

    def to_pretty_json
      ::JSON.pretty_generate @attributes
    end

    def to_json
      ::JSON.generate @attributes
    end

  end
end
