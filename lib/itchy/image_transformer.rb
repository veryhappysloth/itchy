module Itchy
  # Wraps image format conversion methods and helpers.
  class ImageTransformer
    # Registered image formats and archives
    KNOWN_IMAGE_ARCHIVES = %w(ova tar).freeze
    KNOWN_IMAGE_FORMATS  = %w(cow dmg parallels qcow qcow2 raw vdi vmdk vhd).freeze

    # Archive format string msg
    ARCHIVE_STRING = 'POSIX tar archive'

    # REGEX pattern for getting image format
    FORMAT_PATTERN = /format:\s(.*?)$/

    # Creates a class instance.
    #
    # @param options [Hash] configuration options
    def initialize(options = {})
      @options = options
      @inputs = ([] << KNOWN_IMAGE_FORMATS << KNOWN_IMAGE_ARCHIVES).flatten

      #fail ArgumentError, 'Unsupported input image format enabled in configuration! ' \
      #     "#{@inputs.inspect}" unless (@options.input_image_formats - @inputs).empty?
      # fail "Unsupported output image format enabled in configuration! " \
      #     "#{KNOWN_IMAGE_FORMATS.inspect}" unless (@options.required_format - KNOWN_IMAGE_FORMATS).empty?
    end

    # Transforms image(s) associated with the given event to formats
    # preferred by the underlying image datastore. This process includes
    # unpacking of archive & conversion of image files.
    #
    # @param metadata [Itchy::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Itchy::VmcatcherConfiguration] current VMC configuration
    # @return [String] directory with converted images for further processing
    def transform!(metadata, vmcatcher_configuration)
      Itchy::Log.info "[#{self.class.name}] Transforming image format " \
                             "for #{metadata.dc_identifier.inspect}"

      image_file = orig_image_file(metadata, vmcatcher_configuration)

      unless File.file?(image_file)
        Itchy::Log.error "[#{self.class.name}] Event image file - #{image_file}] - does not exist!"
        fail Itchy::Errors::ImageTransformationError
      end

      begin
        if archived?(image_file)
          unpacking_dir = process_archived(metadata, vmcatcher_configuration)
          file_format = format("#{unpacking_dir}/#{metadata.dc_identifier}")
        else
          file_format = format(image_file)
          unpacking_dir = copy_unpacked!(metadata, vmcatcher_configuration)
        end
        if file_format == @options.required_format
          new_file_name = copy_same_format(unpacking_dir, metadata)
        else
          converter = Itchy::FormatConverter.new(unpacking_dir, metadata, vmcatcher_configuration)
          new_file_name = converter.convert!(file_format, @options.required_format, @options.output_dir, @options.qemu_img_binary)
        end
        remove_dir(unpacking_dir)
      rescue Itchy::Errors::FileInspectError, Itchy::Errors::FormatConversionError,
             Itchy::Errors::PrepareEnvError => ex
        fail Itchy::Errors::ImageTransformationError, ex
      end
      new_file_name
    end

    private

    # Checks the given format against a list of available
    # image formats.
    #
    # @param unpacking_dir [String] name and path of the checked file
    # @return [String] image format
    def format(file)

      qemu_command = @options.qemu_img_binary || Itchy::BASIC_QEMU_COMMAND

      image_format_tester = Mixlib::ShellOut.new("#{qemu_command} info #{file}")
      image_format_tester.run_command
      begin
        image_format_tester.error!
      rescue Mixlib::ShellOut::ShellCommandFailed, Mixlib::ShellOut::CommandTimeout,
             Mixlib::ShellOut::InvalidCommandOption => ex
        Itchy::Log.error "[#{self.class.name}] Checking file format for" \
                                "#{file} failed!"
        fail Itchy::Errors::FileInspectError, ex
      end
      file_format = image_format_tester.stdout.scan(FORMAT_PATTERN)[0].flatten.first
      unless KNOWN_IMAGE_FORMATS.include? file_format
        Itchy::Log.error "Image format #{file_format} is unknown and not supported!"
        fail Itchy::Errors::FileInspectError
      end
      file_format
    end


    def process_archive(metadata, vmcatcher_configuration)
      unpacking_dir = nil
      File.open(orig_image_file(metadata, vmcatcher_configuration), "rb") do |file|
        Gem::Package::TarReader.new(file) do |archive|
          disk_name = nil
          archive.each do |entry|
              disk_name = process_ovf(entry.full_name) if File.extname(entry).eql? ".ovf"
          end
          disk = archive.seek(disk_name)
          unpacking_dir = prepare_image_temp_dir(metadata, vmcatcher_configuration)
          File.open("#{unpacking_dir}/#{metadata.dc_identifier}", "wb") do |f|
            f.write(disk.read)
          end
        end
      end
      
      unpacking_dir
    end

    def process_ovf(ovf_file)
      doc = Nokogiri::XML(File.open(ovf_file))
      if doc.css("Envelope DiskSection Disk").count != 1
        Itchy::Log.error "[#{self.class.name}] Unsupported ova, contains 0 or more than one disk!"
        fail Itchy::Errors::FileInspectError
      end
      # return the name of disk
      doc.css("Envelope References File").attr("href").value
    end


    #
    #
    # @param metadata [Itchy::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Itchy::VmcatcherConfiguration] current VMC configuration
    # @return [String] output directory with unpacked files
    def unpack_archived!(metadata, vmcatcher_configuration)
      Itchy::Log.info "[#{self.class.name}] Unpacking image from archive " \
                             "for #{metadata.dc_identifier.inspect}"

      unpacking_dir = prepare_image_temp_dir(metadata, vmcatcher_configuration)
      tar_cmd = ::Mixlib::ShellOut.new('/bin/tar',
                                       "--restrict -C #{unpacking_dir} " \
                                       "-xvf #{orig_image_file(metadata, vmcatcher_configuration)}",
                                       env: nil, cwd: '/tmp')
      tar_cmd.run_command
      begin
        tar_cmd.error!
      rescue Mixlib::ShellOut::ShellCommandFailed, Mixlib::ShellOut::CommandTimeout,
             Mixlib::ShellOut::InvalidCommandOption => ex
        Itchy::Log.error "Unpacking of archive failed with #{tar_cmd.stderr}"
        fail Itchy::Errors::PrepareEnvError, ex
      end

      unpacking_dir
    end

    # Inspect unppacked .ova or .tar files. So far, it checks if there is only one
    # image file of known format and if it is, it's renamed to dc_identifier end its
    # format is determined. Otherwise (for now) its unsupported situation.
    #
    # @param directory [String] name of directory where '.ova' or '.tar' is unpacked
    # @param metadata [Itchy::VmcatcherEvent] event metadata
    # @return [String] format of image or nil.
    def inspect_unpacked_dir(directory, metadata, _identifier)
      dir = Dir.new directory
      counter = 0
      files = dir['*']
      files.each do |file|
        file_format = format("#{directory}/#{file}")
        if KNOWN_IMAGE_FORMATS.include? file_format
          counter += 1
          # unsupported ova content (more than one disk)
          return nil if counter > 1
          File.new("#{directory}/#{file}", 'r').rename(file, "#{metadata.dc_identifier}")
        end
      end
      return nil if counter == 0

      file_format
    end

    # Method moves image files to output directory
    #
    # @param directory [String] name of directory where image is saved
    # @param metadata [Itchy::VmcatcherEvent] event metadata
    def copy_same_format(directory, metadata)
      Itchy::Log.info "[#{self.class.name}] Image #{metadata.dc_identifier.inspect} " \
        'is already in the required format. Moving it to output directory.'

      new_file_name = "#{::Time.now.to_i}_#{metadata.dc_identifier}"
      begin
        ::FileUtils.mv("#{directory}/#{metadata.dc_identifier}",
                          "#{@options.output_dir}/#{new_file_name}")
      rescue SystemCallError => ex
        Itchy::Log.fatal "[#{self.class.name}] Failed to move a file " \
          "for #{metadata.dc_identifier.inspect}: " \
          "#{ex.message}"
        fail Itchy::Errors::PrepareEnvError, ex
      end
      new_file_name
    end

    def remove_dir(path)
      Itchy::Log.debug "[#{self.class.name}] Deleting temporary image dir #{path}."
      begin
        ::FileUtils.remove_dir(path)
      rescue SystemCallError => ex
        Itchy::Log.error "[#{self.class.name}] Failed to delete temporary dir #{path}!"
        fail Itchy::Errors::PrepareEnvError, ex
      end
    end
    # Method for copying image file from vmCatcher cache to processing places
    #
    # @param metadata [Itchy::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Itchy::VmcatcherConfiguration] current VMC configuration
    # @return [String] output directory with copied files
    def copy_unpacked!(metadata, vmcatcher_configuration)
      Itchy::Log.info "[#{self.class.name}] Copying image " \
                             "for #{metadata.dc_identifier.inspect}"
      unpacking_dir = prepare_image_temp_dir(metadata, vmcatcher_configuration).flatten.first
      begin
        ::FileUtils.cp(
          orig_image_file(metadata, vmcatcher_configuration),
          unpacking_dir
        )
      rescue SystemCallError => ex
        Itchy::Log.fatal "[#{self.class.name}] Failed to create a copy " \
                                "for #{metadata.dc_identifier.inspect}: " \
                                "#{ex.message}"
        fail Itchy::Errors::PrepareEnvError, ex
      end

      unpacking_dir
    end

    #
    #
    # @param metadata [Itchy::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Itchy::VmcatcherConfiguration] current VMC configuration
    # @return [String] path to the original image downloaded by VMC
    def orig_image_file(metadata, vmcatcher_configuration)
      "#{vmcatcher_configuration.cache_dir_cache}/#{metadata.dc_identifier}"
    end

    #
    #
    # @param metadata [Itchy::VmcatcherEvent] event metadata
    # @param vmcatcher_configuration [Itchy::VmcatcherConfiguration] current VMC configuration
    # @return [String] path to the newly created image directory
    def prepare_image_temp_dir(metadata, vmcatcher_configuration)
      temp_dir = "#{@options.temp_image_dir}/#{metadata.dc_identifier}"

      begin
        ::FileUtils.mkdir_p temp_dir
      rescue SystemCallError => ex
        Itchy::Log.fatal "[#{self.class.name}] Failed to create a directory " \
                                "for #{metadata.dc_identifier.inspect}: " \
                                "#{ex.message}"
        fail Itchy::Errors::PrepareEnvError, ex
      end
    end

    # Checks if file is archived image (format ova or tar)
    #
    # @param file [String] inspected file name
    # @return [Boolean] archived or not
    def archived?(file)
      image_format_tester = Mixlib::ShellOut.new("file #{file}")
      image_format_tester.run_command
      begin
        image_format_tester.error!
      rescue Mixlib::ShellOut::ShellCommandFailed, Mixlib::ShellOut::CommandTimeout,
             Mixlib::ShellOut::InvalidCommandOption => ex
        Itchy::Log.error "[#{self.class.name}] Checking file format for" \
          "#{file} failed with #{image_format_tester.stderr}"
        fail Itchy::Errors::FileInspectError, ex
                                
      end
      temp = image_format_tester.stdout
      temp.include? ARCHIVE_STRING
    end
  end
end
