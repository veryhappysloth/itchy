module Onevmcatcher::EventHandlers
  # Handler for ProcessPrefix event (starting cache update).
  class ProcessPrefixEventHandler < BaseEventHandler

    def handle!(vmcatcher_event)
      super
      Onevmcatcher::Log.warn "[#{self.class.name}] Just ignoring #{vmcatcher_event.type.inspect}"
    end

  end
end
