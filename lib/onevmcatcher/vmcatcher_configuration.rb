module Onevmcatcher
  # Wraps vmcatcher configuration meta data.
  class VmcatcherConfiguration < VmcatcherEnv

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

    REGISTERED_ENV_KEYS.each do |registered_env_key|
      short_env_key = registered_env_key.gsub(/^VMCATCHER_/, '')

      class_eval %Q|
def #{short_env_key.downcase}
  attributes["#{registered_env_key}"]
end
|
    end

  end
end
