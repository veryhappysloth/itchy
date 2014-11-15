require 'opennebula'

module Onevmcatcher::DatastoreConnectors
  # Connector implementing support for image management in OpenNebula.
  class OpennebulaDatastoreConnector < BaseDatastoreConnector

    ALLOWED_AUTHS = %w(none basic).freeze

    def expire_image!(metadata)
      Onevmcatcher::Log.info "[#{self.class.name}] Expiring image & template " \
                             "for #{metadata.dc_identifier.inspect}"
    end

    def register_image!(metadata)
      Onevmcatcher::Log.info "[#{self.class.name}] Registering image & template" \
                             "for #{metadata.dc_identifier.inspect}"
    end

    private

    # Instantiates ONE client with given credentials.
    #
    # @return [OpenNebula::Client] client instance
    def one_client
      fail Onevmcatcher::Errors::AuthenticationError, "Authentication method " \
           "#{options.auth.inspect} is not supported" unless ALLOWED_AUTHS.include?(options.auth)

      secret = if options.auth == 'basic'
                 "#{options.username}:#{options.password}"
               else
                 nil
               end

      ::OpenNebula::Client.new(
        secret,
        options.endpoint
      )
    end

    # Checks the given object for ONE errors.
    #
    # @param rc [Object] potential error object
    # @return [TrueClass] result
    def check_retval(rc)
      return true unless ::OpenNebula.is_error?(rc)

      case rc.errno
      when ::OpenNebula::Error::EAUTHENTICATION
        fail Onevmcatcher::Errors::AuthenticationError, rc.message
      when ::OpenNebula::Error::EAUTHORIZATION
        fail Onevmcatcher::Errors::NotAuthorizedError, rc.message
      when ::OpenNebula::Error::ENO_EXISTS
        fail Onevmcatcher::Errors::NotFoundError, rc.message
      when ::OpenNebula::Error::EACTION
        fail Onevmcatcher::Errors::WrongStateError, rc.message
      else
        fail rc.message
      end
    end

  end
end
