module Onevmcatcher::EventHandlers
  # Basic handler implementing required methods. Can be used
  # as a dummy for testing purposes.
  class BaseEventHandler

    attr_reader :vmcatcher_configuration
    attr_reader :vmcatcher_event
    attr_reader :settings

    # Event handler constructor.
    #
    # @param vmcatcher_event [Onevmcatcher::VmcatcherEvent] event being handled
    # @param vmcatcher_configuration [Onevmcatcher::VmcatcherConfiguration] current vmcatcher configuration
    # @param settings [Settingslogic] current onevmcatcher configuration
    def initialize(vmcatcher_event, vmcatcher_configuration, settings = Onevmcatcher::Settings)
      fail(
        ArgumentError,
        '\'vmcatcher_event\' must be an instance of Onevmcatcher::VmcatcherEvent!'
      ) unless vmcatcher_event.kind_of? Onevmcatcher::VmcatcherEvent

      fail(
        ArgumentError,
        '\'vmcatcher_configuration\' must be an instance of Onevmcatcher::VmcatcherConfiguration!'
      ) unless vmcatcher_configuration.kind_of? Onevmcatcher::VmcatcherConfiguration

      @vmcatcher_configuration = vmcatcher_configuration
      @vmcatcher_event = vmcatcher_event
      @settings = settings
    end

    # Triggers a handling procedure on the registered event.
    def handle!
      Onevmcatcher::Log.info "[#{self.class.name}] Handling " \
                             "#{vmcatcher_event.type.inspect} " \
                             "for #{vmcatcher_event.dc_identifier.inspect}"
    end

  end
end
