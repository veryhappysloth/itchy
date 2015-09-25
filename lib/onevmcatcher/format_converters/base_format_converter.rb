module Onevmcatcher::FormantConverters


  class BaseFormatConverter

    attr_reader :vmcatcher_configuration, :metadata, :unpacking_dir

    def initialize(unpacking_dir, metadata, vmcatcher_configuration)
      unless vmcatcher_configuration.kind_of?(Onevmcatcher::VmcatcherConfiguration)
        fail ArgumentError, '\'vmcatcher_configuration\' must be an instance of ' \
                            'Onevmcatcher::VmcatcherConfiguration!'
      end

      @unpacking_dir = unpacking_dir
      @metadata = metadata
      @vmcatcher_configuration = vmcatcher_configuration
    end

    def convert!(file_format)
    end

  end
end
