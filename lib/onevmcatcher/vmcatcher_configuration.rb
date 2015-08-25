module Onevmcatcher
  # Wraps vmcatcher configuration meta data.
  class VmcatcherConfiguration < VmcatcherEnv

    # Known methods names used by this class
    KNOWN_METHOD_NAMES = [
      'rdbms',
      'cache_event',
      'log_conf',
      'dir_cert',
      'cache_dir_cache',
      'cache_dir_download',
      'cache_dir_expire',
      'cache_action_download',
      'cache_action_check',
      'cache_action_expire'
    ].freeze

    # Prefix for making vmcatcher attributes
    VMCATCHER_ATTR_PREFIX = "VMCATCHER_"

    # Known vmcatcher configuration attributes
    REGISTERED_ENV_KEYS = [
      'VMCATCHER_RDBMS',
      'VMCATCHER_CACHE_EVENT',
      'VMCATCHER_LOG_CONF',
      'VMCATCHER_DIR_CERT',
      'VMCATCHER_CACHE_DIR_CACHE',
      'VMCATCHER_CACHE_DIR_DOWNLOAD',
      'VMCATCHER_CACHE_DIR_EXPIRE',
      'VMCATCHER_CACHE_ACTION_DOWNLOAD',
      'VMCATCHER_CACHE_ACTION_CHECK',
      'VMCATCHER_CACHE_ACTION_EXPIRE'
    ].freeze

    #    REGISTERED_ENV_KEYS.each do |registered_env_key|
    #      short_env_key = registered_env_key.gsub(/^VMCATCHER_/, '')

    #      class_eval %Q|
    #def #{short_env_key.downcase}
    #  attributes["#{registered_env_key}"]
    #end
    #|
    #    end
    def method_missing(method_id, *arguments, &block)
      if KNOWN_METHOD_NAMES.include? method_id.to_s
        self.class.send :define_method, method_id do
          temp = VMCATCHER_ATTR_PREFIX + method_id.to_s.upcase
          attributes["#{temp}"]
        end
        self.send(method_id)
      else
        super
      end
    end

    def respond_to?(method_id, include_private = false)
      if KNOWN_METHOD_NAMES.include? method_id.to_s
        true
      else
        super
      end
    end

  end
end
