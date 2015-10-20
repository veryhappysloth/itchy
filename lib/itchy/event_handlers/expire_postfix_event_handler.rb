module Itchy::EventHandlers
  # Handler for ExpirePostfix event (image expired).
  class ExpirePostfixEventHandler < BaseEventHandler

    # Handles an ExpirePostfix event.
    #
    # @param vmcatcher_event [Itchy::VmcatcherEvent] vmcatcher event to handle
    # @param event_name [String] name of the event
    def handle!(vmcatcher_event, event_name)
      super
      Itchy::Log.info "[#{self.class.name}] Handling expired image " \
                             "for #{vmcatcher_event.dc_identifier.inspect}"
      save_descriptor(create_descriptor(vmcatcher_event), event_name)
    end

    private
    # Create appliance descriptor from VMCATCHER_EVENT metadata.
    #
    # @param metadata [Itchy::VmcatcherEvent] vmcatcher event to get metadata from
    # @return [String] json form of created description
    def create_descriptor(metadata)
      Itchy::Log.debug "[#{self.class.name}] Creating appliance descriptor"
      appliance = ::Cloud::Appliance::Descriptor::Appliance.new :action => :expiration
      appliance.version = metadata.hv_version
      appliance.identifier = metadata.dc_identifier

      descriptor = appliance.to_json
    end

  end
end
