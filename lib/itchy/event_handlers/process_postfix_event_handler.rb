module Itchy::EventHandlers
  # Handler for ProcessPostfix event (finished cache update).
  class ProcessPostfixEventHandler < BaseEventHandler
    def handle!(vmcatcher_event, event_file)
      super
      Itchy::Log.warn "[#{self.class.name}] Just ignoring #{vmcatcher_event.type.inspect}"
    end
  end
end
