module Onevmcatcher::FormatConverters
  # Image converter for files unpacked from ova or tar.
  class UnpackedFormatConverter

    def convert!(unpacking_dir, file_format, metadata, vmcatcher_configuration)
      super
      Onevmcatcher::Log.info "[#{self.class.name}] Converting image "

    end
  end
end
