module Onevmcatcher::EventHandlers
  # Handler for ProcessPostfix event (finished cache update).
  class ProcessPostfixEventHandler < BaseEventHandler

    def handle!(vmcatcher_event)
      super
      Onevmcatcher::Log.warn "[#{self.class.name}] Just ignoring #{vmcatcher_event.type.inspect}"
    end

  end
end
