require 'active_support/all'
require 'settingslogic'
require 'multi_json'
require 'opennebula'
require 'mixlib/shellout'
require 'logger'

# Wraps all internals of the handler.
module Onevmcatcher; end

require 'onevmcatcher/version'
require 'onevmcatcher/constants'
require 'onevmcatcher/log'
require 'onevmcatcher/event_handlers'
