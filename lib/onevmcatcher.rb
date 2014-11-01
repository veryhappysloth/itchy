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
require 'onevmcatcher/settings'
require 'onevmcatcher/log'
require 'onevmcatcher/event_handlers'
require 'onevmcatcher/datastore_connectors'
require 'onevmcatcher/metadata_archiver'
require 'onevmcatcher/image_syncmaster'
require 'onevmcatcher/image_transformer'
