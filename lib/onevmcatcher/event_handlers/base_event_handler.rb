module Onevmcatcher::EventHandlers
  # Basic handler implementing required methods. Can be used
  # as a dummy for testing purposes.
  class BaseEventHandler

    attr_reader :vmc_configuration
    attr_reader :event_env
    attr_reader :settings

    def initialize(env, settings = Onevmcatcher::Settings)
      validate_env(env)
      @vmc_configuration = select_vmc_configuration(env)
      @event_env = select_event_env(env)
      @settings = settings
    end

    def handle!
      Onevmcatcher::Log.info "[#{self.class.name}] Handling " \
                             "#{event_type.inspect} " \
                             "for #{event_dc_id.inspect}"
    end

    private

    def event_type
      event_env['VMCATCHER_EVENT_TYPE']
    end

    def event_ad_mpuri
      event_env['VMCATCHER_EVENT_AD_MPURI']
    end

    def event_dc_id
      event_env['VMCATCHER_EVENT_DC_IDENTIFIER']
    end

    def select_vmc_configuration(env)
      select_from_env env, 'CONF_ENV'
    end

    def select_event_env(env)
      select_from_env env, 'EVENT_ENV'
    end

    def select_from_env(env, const_type)
      const_ary = Onevmcatcher::Constants.const_get(const_type)

      Onevmcatcher::Log.debug "[#{self.class.name}] Looking for " \
                              "#{const_ary.inspect} in #{env.inspect}"
      env = env.select { |key,_| const_ary.include? key }

      if env.blank?
        Onevmcatcher::Log.fatal "[#{self.class.name}] No " \
                                "#{const_type.inspect} information " \
                                "found in 'env'"
        fail ArgumentError, 'Environment look-up failed!'
      end

      env
    end

    def validate_env(env)
      fail ArgumentError, '\'env\' must be hash-like!' unless env.kind_of? Hash
      fail ArgumentError, '\'env\' must not be empty!' if env.blank?
    end

  end
end
