module Itchy::EventHandlers
  # Handler for SubscriptionImageNew event (new image added to image list).
  class SubscriptionImageNewEventHandler < BaseEventHandler
    def handle!(vmcatcher_event, event_file)
      super
      Itchy::Log.warn "[#{self.class.name}] Just ignoring #{vmcatcher_event.type.inspect}"
    end
  end
end
