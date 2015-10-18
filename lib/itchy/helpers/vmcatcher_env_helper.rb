module Itchy::Helpers
  # Wraps static helper methods for accessing environment variables
  # provided by vmcatcher.
  module VmcatcherEnvHelper

    # Selects only relevant +env+ entries and throws the rest away.
    # Throws Itchy::Errors::EnvLookupError if the result is
    # empty.
    #
    # @param env [Object] environment object convertible to a hash
    # @param relevant_keys [Array] an array of string keys to look for in +env+
    # @return [Hash] cleaned up hash containing only relevant entries
    def self.select_from_env(env, relevant_keys)
      Itchy::Log.debug "[#{self.name}] Looking for " \
                              "#{relevant_keys.inspect} in #{env.inspect}"
      env = env.select { |key,_| relevant_keys.include? key }

      if env.blank?
        Itchy::Log.fatal "[#{self.name}] No relevant information " \
                                "found in 'env'"
        fail(
          Itchy::Errors::EnvLookupError,
          'Environment look-up failed! Result is empty!'
        )
      end

      env
    end

    # Converts +env+ object to a hash.
    #
    # @param env [Object] environment object convertible to a hash
    # @return [Hash] converted environment object
    def self.normalize_env(env)
      return env if env.kind_of? Hash

      fail(
        Itchy::Errors::EnvLookupError,
        "'env' must be convertible to a hash!"
      ) unless env.respond_to?(:to_hash)

      env.to_hash
    end

  end
end
