module Onevmcatcher
  # Wraps vmcatcher event meta data.
  class VmcatcherEvent < VmcatcherEnv

    # Known event attributes used by vmcatcher
    REGISTERED_ENV_KEYS = [
      'VMCATCHER_EVENT_TYPE',
      'VMCATCHER_EVENT_DC_DESCRIPTION',
      'VMCATCHER_EVENT_DC_IDENTIFIER',
      'VMCATCHER_EVENT_DC_TITLE',
      'VMCATCHER_EVENT_HV_HYPERVISOR',
      'VMCATCHER_EVENT_HV_SIZE',
      'VMCATCHER_EVENT_HV_URI',
      'VMCATCHER_EVENT_HV_FORMAT',
      'VMCATCHER_EVENT_HV_VERSION',
      'VMCATCHER_EVENT_SL_ARCH',
      'VMCATCHER_EVENT_SL_CHECKSUM_SHA512',
      'VMCATCHER_EVENT_SL_COMMENTS',
      'VMCATCHER_EVENT_SL_OS',
      'VMCATCHER_EVENT_SL_OSVERSION',
      'VMCATCHER_EVENT_IL_DC_IDENTIFIER',
      'VMCATCHER_EVENT_AD_MPURI',
      'VMCATCHER_EVENT_FILENAME',
      'VMCATCHER_EVENT_VO'
    ].freeze

    REGISTERED_ENV_KEYS.each do |registered_env_key|
      short_env_key = registered_env_key.gsub(/^VMCATCHER_EVENT_/, '')

      class_eval %Q|
def #{short_env_key.downcase}
  attributes["#{registered_env_key}"]
end
|
    end

  end
end
