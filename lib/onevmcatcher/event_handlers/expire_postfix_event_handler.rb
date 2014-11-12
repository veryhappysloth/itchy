module Onevmcatcher::EventHandlers
  # Handler for ExpirePostfix event (image expired).
  class ExpirePostfixEventHandler < BaseEventHandler

    def handle!(vmcatcher_event)
      super
      Onevmcatcher::Log.warn "[#{self.class.name}] Just ignoring #{vmcatcher_event.type.inspect}"
    end

  end
end
