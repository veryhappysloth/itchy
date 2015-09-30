module Onevmcatcher

  class FormatConverter

    def initialize(unpacking_dir, metadata, vmcatcher_configuration)
      unless vmcatcher_configuration.kind_of?(Onevmcatcher::VmcatcherConfiguration)
        fail ArgumentError, '\'vmcatcher_configuration\' must be an instance of ' \
                            'Onevmcatcher::VmcatcherConfiguration!'
      end

      @unpacking_dir = unpacking_dir
      @metadata = metadata
      @vmcatcher_configuration = vmcatcher_configuration
    end

    def convert!(file_format, required_format)
      Onevmcatcher::Log.info "[#{self.class.name}] Converting image " \
                             "#{metadata.dc_identifier.inspect} from " \
                             "original format: #{file_format} to " \
                             "required format: #{required_format}."
      
      convert_cmd = Mixlub::Shellout.new("qemu-img convert",
                                       "-f #{original_format} " \
                                       "-O #{required_format} " \
                                       "#{unpacking_dir}/#{metadata.dc_identifier} " \
                                       "#{unpacking_dir}/converted/" \
                                       "#{metadata.dc_identifier.inspect}")
      
      convert_cmd.run_command
    end

  end
end
