module Onevmcatcher::EventHandlers
  # Handler for AvailablePostfix event (image available).
  class AvailablePostfixEventHandler < BaseEventHandler

    def handle!(vmcatcher_event)
      super
      Onevmcatcher::Log.info "[#{self.class.name}] Handling updated image " \
                             "for #{vmcatcher_event.dc_identifier.inspect}"

      create_descriptor(vmcatcher_event)
      image_transformer_instance = Onevmcatcher::ImageTransformer.new(@options)
      image_transformer_instance.transform!(vmcatcher_event,vmcatcher_configuration)
    end

private
    # Create appliance descriptor from VMCATCHER_EVENT metadata.
    def create_descriptor(metadata)
      os = ::Cloud::Appliance::Descriptor::Os.new(:distribution => metadata.sl_osversion,
                                                :version => metadata.sl_osversion)
      disk = ::Cloud::Appliance::Descriptor::Disk.new(:type => :os,
                                                    :format => @options.required_format)

      appliance = ::Cloud::Appliance::Descriptor::Appliance.new :action => :create
      appliance.title = metadata.dc_title
      appliance.version = metadata.hv_version
      appliance.os = os
      appliance.add_group metadata.vo 
      appliance.description = metadata.dc_title
      appliance.identifier = metadata.dc_identifier
      appliance.attributes = metadata.to_hash

      descriptor = appliance.to_json
    end

  end
end
