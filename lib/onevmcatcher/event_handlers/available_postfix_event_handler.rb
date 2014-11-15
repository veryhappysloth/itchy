module Onevmcatcher::EventHandlers
  # Handler for AvailablePostfix event (image available).
  class AvailablePostfixEventHandler < BaseEventHandler

    def handle!(vmcatcher_event)
      super
      Onevmcatcher::Log.info "[#{self.class.name}] Uploading updated image " \
                             "for #{vmcatcher_event.dc_identifier.inspect}"
      # TODO: integrate ImageTransformer
      datastore_instance.register_image! vmcatcher_event
    end

  end
end
