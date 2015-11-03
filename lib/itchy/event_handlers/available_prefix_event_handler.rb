module Itchy::EventHandlers
  # Handler for AvailablePrefix event (image will be available).
  class AvailablePrefixEventHandler < BaseEventHandler
    def handle!(vmcatcher_event, event_file)
      super
      Itchy::Log.info "[#{self.class.name}] Handling #{vmcatcher_event.type.inspect}" \
        'This kind of event is just logged, nothing to process.'
    end
  end
end
