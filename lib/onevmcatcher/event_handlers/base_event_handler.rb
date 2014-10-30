module Onevmcatcher::EventHandlers
  class BaseEventHandler

    def handle(env)
      Onevmcatcher::Log.info "[#{self.class.name}] Handling incoming event w/ env = #{env.inspect}"
    end

  end
end
