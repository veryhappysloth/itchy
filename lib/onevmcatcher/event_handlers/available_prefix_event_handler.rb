module Onevmcatcher::EventHandlers
  # Handler for AvailablePrefix event (image will be available).
  class AvailablePrefixEventHandler < BaseEventHandler

    def handle!(vmcatcher_event)
      super
      Onevmcatcher::Log.warn "[#{self.class.name}] Just ignoring #{vmcatcher_event.type.inspect}"
    end

  end
end
