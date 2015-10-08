module Onevmcatcher::EventHandlers
  # Handler for AvailablePostfix event (image available).
  class AvailablePostfixEventHandler < BaseEventHandler

    def handle!(vmcatcher_event)
      super
      Onevmcatcher::Log.info "[#{self.class.name}] Handling updated image " \
                             "for #{vmcatcher_event.dc_identifier.inspect}"

      image_transformer_instance = Onevmcatcher::ImageTransformer.new()
      image_transformer_instance.transform!(vmcatcher_event,vmcatcher_configuration)
    end

  end
end
