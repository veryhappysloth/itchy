module Onevmcatcher
  # Wraps image format conversion methods and helpers.
  class ImageTransformer

    # Registered image formats and archives
    KNOWN_IMAGE_ARCHIVES = %w(ova tar).freeze
    KNOWN_IMAGE_FORMATS  = %w(cow dmg parallels qcow qcow2 raw vdi vmdk vhd).freeze

    # Archive format string msg
    ARCHIVE_STRING = "POSIX tar archive"

    # REGEX pattern for getting image format
    FORMAT_PATTERN = /format:\s(.*?)$/

    # Creates a class instance.
    #
    # @param options [Hash] configuration options
    def initialize(options = {})
      @options = options
      @inputs = ([] << KNOWN_IMAGE_FORMATS << KNOWN_IMAGE_ARCHIVES).flatten

      fail "Unsupported input image format enabled in configuration! " \
           "#{@inputs.inspect}" unless (@options.input_image_formats - @inputs).empty?
      #fail "Unsupported output image format enabled in configuration! " \
      #     "#{KNOWN_IMAGE_FORMATS.inspect}" unless (@options.required_format - KNOWN_IMAGE_FORMATS).empty?
    end

    # Transforms image(s) associated with the given event to formats
    # preferred by the underlying image datastore. This process includes
    # unpacking of archive & conversion of image files.
    #
    # @param metadata [Onevmcatcher::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current VMC configuration
    # @return [String] directory with converted images for further processing
    def transform!(metadata, vmcatcher_configuration)
      Onevmcatcher::Log.info "[#{self.class.name}] Transforming image format " \
                             "for #{metadata.dc_identifier.inspect}"

      if archived?(metadata.dc_identifier.inspect)
        unpacking_dir = unpack_archived!(metadata, vmcatcher_configuration)
        file_format = inspect_unpacked_dir(unpacking_dir, metadata)
      else
        file_format = format(orig_image_file(metadata, vmcatcher_configuration))
        unpacking_dir = copy_unpacked!(metadata, vmcatcher_configuration)
      end
      if file_format == @options.required_format
        #TODO just simlink to output_dir
      else
        converter = Onevmcatcher::FormatConverter.new(unpacking_dir, metadata, vmcatcher_configuration)
        converter.convert!(file_format, @options.required_format, @options.output_dir)
      end
    end

    private

    # Checks the given format against a list of available
    # image formats.
    #
    # @param unpacking_dir [String] name and path of the checked file
    # @return [String] image format
    def format(file)  
      image_format_tester = Mixlib::ShellOut.new("qemu-img info #{file}")
      image_format_tester.run_command
      if image_format_tester.error?
        Onevmcatcher::Log.error "[#{self.class.name}] Checking file format for" \
                                "#{file} failed!"
      end
      file_format = image_format_tester.stdout.scan(FORMAT_PATTERN)[0].flatten.first
      unless KNOWN_IMAGE_FORMATS.include? file_format
        fail "Image format #{file_format}" \
             " is unknown and not supported!"
      end
      file_format
    end

    #
    #
    # @param metadata [Onevmcatcher::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current VMC configuration
    # @return [String] output directory with unpacked files
    def unpack_archived!(metadata, vmcatcher_configuration)
      Onevmcatcher::Log.info "[#{self.class.name}] Unpacking image from archive " \
                             "for #{metadata.dc_identifier.inspect}"

      unpacking_dir = prepare_image_temp_dir(metadata, vmcatcher_configuration)
      tar_cmd = ::Mixlib::ShellOut.new("/bin/tar",
                                       "--restrict -C #{unpacking_dir} " \
                                       "-xvf #{orig_image_file(metadata, vmcatcher_configuration)}",
                                       :env => nil, :cwd => '/tmp')
      tar_cmd.run_command
      tar_cmd.error!

      unpacking_dir
    end

    #
    #
    # @param directory [String] name of directory where '.ova' or '.tar' is unpacked
    # @param metadata [Onevmcatcher::VmcatcherEvent] event metadata
    # @return [String] format of image or nil.
    def inspect_unpacked_dir(directory, metadata, identifier)
      dir = Dir.new "directory"
      counter = 0
      files = dir["*"]
      files each do |file|
        file_format = format("#{directory}/#{file}")
        if KNOWN_IMAGE_FORMATS.include? file_format
          counter+1
          # unsupported ova content (more than one disk)
          return nil if counter > 1
          File.new("#{directory}/#{file}","r").rename(file, "#{metadata.dc_identifier}.#{file_format}")
        end
      end
        return nil if counter == 0

        file_format
      end

    #
    #
    # @param metadata [Onevmcatcher::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current VMC configuration
    # @return [String] output directory with copied files
    def copy_unpacked!(metadata, vmcatcher_configuration)
      Onevmcatcher::Log.info "[#{self.class.name}] Copying image " \
                             "for #{metadata.dc_identifier.inspect}"
      unpacking_dir = prepare_image_temp_dir(metadata, vmcatcher_configuration).flatten.first
      begin
        ::FileUtils.ln_sf(
          orig_image_file(metadata, vmcatcher_configuration),
          unpacking_dir
        )
      rescue => ex
        Onevmcatcher::Log.fatal "[#{self.class.name}] Failed to create a link (copy) " \
                                "for #{metadata.dc_identifier.inspect}: " \
                                "#{ex.message}"
        fail ex
      end

      unpacking_dir
  end

    #
    #
    # @param metadata [Onevmcatcher::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current VMC configuration
    # @return [String] path to the original image downloaded by VMC
    def orig_image_file(metadata, vmcatcher_configuration)
      "#{vmcatcher_configuration.cache_dir_cache}/#{metadata.dc_identifier}"
    end

    #
    #
    # @param metadata [Onevmcatcher::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current VMC configuration
    # @return [String] path to the newly created image directory
    def prepare_image_temp_dir(metadata, vmcatcher_configuration)
      temp_dir = "#{vmcatcher_configuration.cache_dir_cache}/temp/#{metadata.dc_identifier}"

      begin
        ::FileUtils.mkdir_p temp_dir
      rescue => ex
        Onevmcatcher::Log.fatal "[#{self.class.name}] Failed to create a directory " \
                                "for #{metadata.dc_identifier.inspect}: " \
                                "#{ex.message}"
        fail ex
      end
    end

    #
    #
    # @param file [String] inspected file name
    # @return [Boolean] archived or not
    def archived?(file)
      image_format_tester = Mixlib::ShellOut.new("file #{file}")
      image_format_tester.run_command
      if image_format_tester.error?
        Onevmcatcher::Log.error "[#{self.class.name}] Checking file format for" \
                                "#{file} failed!"
      end
      temp = image_format_tester.stdout
      temp.include? ARCHIVE_STRING
    end
  
  end
end
