module Onevmcatcher
  # Wraps image format conversion methods and helpers.
  class ImageTransformer

    # Registered image formats and archives
    KNOWN_IMAGE_ARCHIVES = %w(ova tar).freeze
    KNOWN_IMAGE_FORMATS  = %w(cow dmg parallels qcow qcow2 raw vdi vmdk).freeze

    # Creates a class instance.
    #
    # @param options [Hash] configuration options
    def initialize(options = {})
      @options = options
      @inputs = ([] << KNOWN_IMAGE_FORMATS << KNOWN_IMAGE_ARCHIVES).flatten

      fail "Unsupported input image format enabled in configuration! " \
           "#{@inputs.inspect}" unless (@options.input_image_formats - @inputs).empty?
      fail "Unsupported output image format enabled in configuration! " \
           "#{KNOWN_IMAGE_FORMATS.inspect}" unless (@options.output_image_formats - KNOWN_IMAGE_FORMATS).empty?
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
      image_format = (metadata.hv_format || '').downcase
      unless valid_format?(image_format)
        fail "Image format #{image_format.inspect} " \
             "is not supported! Supported: #{@inputs.inspect}"
      end

      unless enabled_format?(image_format)
        fail "Image format #{image_format.inspect} " \
             "is not enabled! Enabled: #{@options.input_image_formats.inspect}"
      end

      unpacking_dir = if archive?(image_format)
                        unpack_archived!(metadata, vmcatcher_configuration)
                      else
                        copy_unpacked!(metadata, vmcatcher_configuration)
                      end

      convert_unpacked!(unpacking_dir, metadata, vmcatcher_configuration)
    end

    private

    # Checks the given format against a list of available
    # image formats.
    #
    # @param image_format [String] name of the image format
    # @return [Boolean] validity of the given image format
    def valid_format?(image_format)
      @inputs.include?(image_format)
    end

    # Checks the given format against a list of enabled
    # image formats.
    #
    # @param image_format [String] name of the image format
    # @return [Boolean] enabled or not
    def enabled_format?(image_format)
      @options.input_image_formats.include?(image_format)
    end

    # Checks the given format against a list of known
    # archive formats containing images inside.
    #
    # @param image_format [String] name of the image format
    # @return [Boolean] format is or isn't an archive with images inside
    def archive?(image_format)
      KNOWN_IMAGE_ARCHIVES.include?(image_format)
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
    # @param metadata [Onevmcatcher::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current VMC configuration
    # @return [String] output directory with copied files
    def copy_unpacked!(metadata, vmcatcher_configuration)
      Onevmcatcher::Log.info "[#{self.class.name}] Copying image " \
                             "for #{metadata.dc_identifier.inspect}"
      unpacking_dir = prepare_image_temp_dir(metadata, vmcatcher_configuration)

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
    # @param unpacking_dir [String] directory with unpacked image files
    # @param metadata [Onevmcatcher::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current VMC configuration
    # @return [String] directory with converted images for further processing
    def convert_unpacked!(unpacking_dir, metadata, vmcatcher_configuration)
      Onevmcatcher::Log.info "[#{self.class.name}] Converting image(s) " \
                             "in #{unpacking_dir.inspect} for #{metadata.dc_identifier.inspect}"
      # TODO: impl
      "#{unpacking_dir}/converted"
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
      temp_dir = "#{vmcatcher_configuration.cache_dir_cache}/#{metadata.dc_identifier}"

      begin
        ::FileUtils.mkdir_p temp_dir
      rescue => ex
        Onevmcatcher::Log.fatal "[#{self.class.name}] Failed to create a directory " \
                                "for #{metadata.dc_identifier.inspect}: " \
                                "#{ex.message}"
        fail ex
      end
    end

  end
end
