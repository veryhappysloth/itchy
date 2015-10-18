module Itchy

  class FormatConverter

    def initialize(unpacking_dir, metadata, vmcatcher_configuration)
      unless vmcatcher_configuration.kind_of?(Itchy::VmcatcherConfiguration)
        fail ArgumentError, '\'vmcatcher_configuration\' must be an instance of ' \
                            'Itchy::VmcatcherConfiguration!'
      end

      @unpacking_dir = unpacking_dir
      @metadata = metadata
      @vmcatcher_configuration = vmcatcher_configuration
    end

    def convert!(file_format, required_format, output_dir)
      Itchy::Log.info "[#{self.class.name}] Converting image " \
                             "#{@metadata.dc_identifier.inspect} from " \
                             "original format: #{file_format} to " \
                             "required format: #{required_format}."

      convert_cmd = Mixlib::ShellOut.new("qemu-img convert -f #{file_format} -O #{required_format} #{@unpacking_dir}/#{@metadata.dc_identifier} #{output_dir}/#{@metadata.dc_identifier}")
      convert_cmd.run_command
    end

  end
end
