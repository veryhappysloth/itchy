module Itchy::EventHandlers
  # Handler for ExpirePostfix event (image expired).
  class ExpirePostfixEventHandler < BaseEventHandler

    def handle!(vmcatcher_event)
      super
      Itchy::Log.info "[#{self.class.name}] Handling expired image " \
                             "for #{vmcatcher_event.dc_identifier.inspect}"
      datastore_instance.expire_image! vmcatcher_event
    end

  end
end
