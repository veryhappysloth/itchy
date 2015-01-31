module Onevmcatcher
  # Wraps image format conversion methods and helpers.
  class ImageTransformer

    KNOWN_IMAGE_ARCHIVES = %w(ova tar tar.gz).freeze
    KNOWN_IMAGE_FORMATS  = %w(cow dmg parallels qcow qcow2 raw vdi vmdk).freeze

    def initialize(options = {})
      @options = options
      @inputs = ([] << KNOWN_IMAGE_FORMATS << KNOWN_IMAGE_ARCHIVES).flatten

      fail "Unsupported input image format enabled in configuration! " \
           "#{@inputs.inspect}" unless (@options.input_image_formats - @inputs).empty?
      fail "Unsupported output image format enabled in configuration! " \
           "#{KNOWN_IMAGE_FORMATS.inspect}" unless (@options.output_image_formats - KNOWN_IMAGE_FORMATS).empty?
    end

    def transform!(metadata)
      Onevmcatcher::Log.info "[#{self.class.name}] Transforming image format" \
                             "for #{metadata.dc_identifier.inspect}"
      image_format = (metadata.hv_format || '').downcase
      unless valid_format?(image_format)
        fail "Image format #{image_format.inspect}" \
             "is not supported! Supported: #{@inputs.inspect}"
      end

      unless enabled_format?(image_format)
        fail "Image format #{image_format.inspect}" \
             "is not enabled! Enabled: #{@options.input_image_formats.inspect}"
      end

      if archive?(image_format)
        unpack_archived!(metadata)
      else
        copy_unpacked!(metadata)
      end

      convert_unpacked!(metadata)
    end

    private

    def valid_format?(image_format)
      @inputs.include?(image_format)
    end

    def enabled_format?(image_format)
      @options.input_image_formats.include?(image_format)
    end

    def archive?(image_format)
      KNOWN_IMAGE_ARCHIVES.include?(image_format)
    end

    def unpack_archived!(metadata)
      Onevmcatcher::Log.info "[#{self.class.name}] Unpacking image from archive" \
                             "for #{metadata.dc_identifier.inspect}"
    end

    def copy_unpacked!(metadata)
      Onevmcatcher::Log.info "[#{self.class.name}] Copying image" \
                             "for #{metadata.dc_identifier.inspect}"
    end

    def convert_unpacked!(metadata)
      Onevmcatcher::Log.info "[#{self.class.name}] Converting image" \
                             "for #{metadata.dc_identifier.inspect}"
    end

  end
end
