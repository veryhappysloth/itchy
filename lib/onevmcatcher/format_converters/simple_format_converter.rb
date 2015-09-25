module Onevmcatcher::FormatConverters
  # Image converter for converting simple image.
  class SimpleFormatConverter < BaseFormatConverter

    def convert!(original_format, required_format)
      super
      Onevmcatcher::Log.info "[#{self.class.name}] Converting image " \
                             " #{metadata.dc_identifier.inspect} from " \
                             "original format: #{file_format} to " \
                             "required format: #{required_format}."
      
      convert_cmd = Mixlib::Shellout.new("qemu-img convert", 
                                         "-f #{original_format} " \
                                         "-O #{required_format} " \
                                         "#{unpacking_dir}/#{metadata.dc_identifier.inspect} " \ 
                                         "#{unpacking_dir}/converted/" \
                                         "#{metadata.dc_identifier.inspect}")
      convert_cmd.run_command
    end

  end
end
