module Itchy::EventHandlers
  # Handler for AvailablePostfix event (image available).
  class AvailablePostfixEventHandler < BaseEventHandler
    # Handles an AvailablePostfix event.
    #
    # @param vmcatcher_event [Itchy::VmcatcherEvent] vmcatcher event to handle
    # @param event_name [String] name of the event
    def handle!(vmcatcher_event, event_name)
      super
      Itchy::Log.info "[#{self.class.name}] Handling updated image " \
                             "for #{vmcatcher_event.dc_identifier.inspect}"
      save_descriptor(create_descriptor(vmcatcher_event), event_name)
      image_transformer_instance = Itchy::ImageTransformer.new(@options)
      image_transformer_instance.transform!(vmcatcher_event, vmcatcher_configuration)
    end

    private

    # Create appliance descriptor from VMCATCHER_EVENT metadata.
    #
    # @param metadata [Itchy::VmcatcherEvent] vmcatcher event to get metadata from
    # @return [String] json form of created descriptor
    def create_descriptor(metadata)
      os = ::Cloud::Appliance::Descriptor::Os.new(distribution: metadata.sl_osversion,
                                                  version: metadata.sl_osversion)
      disk = ::Cloud::Appliance::Descriptor::Disk.new(type: :os,
                                                      format: @options.required_format,
                                                      path: "#{@options.output_dir}/#{metadata.dc_identifier}")

      appliance = ::Cloud::Appliance::Descriptor::Appliance.new action: :registration
      appliance.title = metadata.dc_title
      appliance.version = metadata.hv_version
      appliance.os = os
      appliance.add_disk disk
      appliance.add_group metadata.vo
      appliance.description = metadata.dc_title
      appliance.identifier = metadata.dc_identifier
      appliance.attributes = metadata.to_hash

      descriptor = appliance.to_json
    end
  end
end
