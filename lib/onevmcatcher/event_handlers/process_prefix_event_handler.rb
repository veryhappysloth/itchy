module Onevmcatcher::EventHandlers
  # Handler for ProcessPrefix event (starting cache update).
  class ProcessPrefixEventHandler < BaseEventHandler

    def handle!(vmcatcher_event, file)
      super
      Onevmcatcher::Log.info "[#{self.class.name}] Handling #{vmcatcher_event.type.inspect}" \
        "This kind of event is just logged, nothing to process."
    end

  end
end
