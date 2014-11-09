module Onevmcatcher
  # Provides option parsing capabilities and defaults.
  class Opts

    AUTH_METHODS = [:basic, :none].freeze
    LOG_OUTPUTS = [:stdout, :stderr].freeze
    LOG_LEVELS = [:debug, :error, :fatal, :info, :unknown, :warn].freeze

    def self.parse(args)
      # set some defaults
      options = ::Hashie::Mash.new
      set_defaults(options)

      # parse incoming options
      opts = OptionParser.new do |opts|
        opts.banner = %{Usage: onevmcatcher [OPTIONS]}

        opts.separator ""
        opts.separator "Options:"

        opts.on("-e",
                "--endpoint URL",
                String,
                "Datastore endpoint URL, defaults to #{options.endpoint.inspect}") do |endpoint|
          options.endpoint = URI(endpoint).to_s
        end

        opts.on("-m",
                "--metadata-dir PATH",
                String,
                "Path to metadata directory, defaults to #{options.metadata_dir.inspect}") do |metadata_dir|
          raise ArgumentError, "Path specified in --metadata-dir is not a directory!" unless File.directory? metadata_dir
          raise ArgumentError, "Path specified in --metadata-dir is not writable!" unless File.writable? metadata_dir

          options.metadata_dir = metadata_dir
        end

        opts.on("-o",
                "--datastore TYPE",
                String,
                "Datastore type, defaults to #{options.datastore.inspect}") do |datastore|
          options.datastore = datastore
        end

        opts.on("-a",
                "--auth METHOD",
                AUTH_METHODS,
                "Authentication method, only: [ #{AUTH_METHODS.join(' | ')} ], defaults " \
                "to #{options.auth.type.inspect}") do |auth|
          options.auth.type = auth.to_s
        end

        opts.on("-t",
                "--timeout SEC",
                Integer,
                "Default timeout for all HTTP connections, in seconds") do |timeout|
          raise "Timeout has to be a number larger than 0!" if timeout < 1
          options.timeout = timeout
        end

        opts.on("-u",
                "--username USER",
                String,
                "Username for basic authentication, defaults to " \
                "#{options.auth.username.inspect}") do |username|
          options.auth.username = username
        end

        opts.on("-p",
                "--password PASSWORD",
                String,
                "Password for basic authentication") do |password|
          options.auth.password = password
        end

        opts.on("-c",
                "--ca-path PATH",
                String,
                "Path to CA certificates directory, defaults to #{options.auth.ca_path.inspect}") do |ca_path|
          raise ArgumentError, "Path specified in --ca-path is not a directory!" unless File.directory? ca_path
          raise ArgumentError, "Path specified in --ca-path is not readable!" unless File.readable? ca_path

          options.auth.ca_path = ca_path
        end

        opts.on("-f",
                "--ca-file PATH",
                String,
                "Path to CA certificates in a file") do |ca_file|
          raise ArgumentError, "File specified in --ca-file is not a file!" unless File.file? ca_file
          raise ArgumentError, "File specified in --ca-file is not readable!" unless File.readable? ca_file

          options.auth.ca_file = ca_file
        end

        opts.on("-s",
                "--skip-ca-check",
                "Skip server certificate verification, NOT recommended") do
          silence_warnings { OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE) }
        end

        opts.on("-l",
                "--log-to OUTPUT",
                LOG_OUTPUTS,
                "Log to the specified device, only: [ #{LOG_OUTPUTS.join(' | ')} ], defaults to 'stderr'") do |log_to|
          options.log.out = STDOUT if log_to.to_s == "stdout"
        end

        opts.on("-b",
                "--log-level LEVEL",
                LOG_LEVELS,
                "Set the specified logging level, only: [ #{LOG_LEVELS.join(' | ')} ]") do |log_level|
          unless options.log.level == Onevmcatcher::Log::DEBUG
            options.log.level = Onevmcatcher::Log.const_get(log_level.to_s.upcase)
          end
        end

        opts.on_tail("-d",
                     "--debug",
                     "Enable debugging messages") do |debug|
          options.debug = debug
          options.log.level = Onevmcatcher::Log::DEBUG
        end

        opts.on_tail("-h",
                     "--help",
                     "Show this message") do
          puts opts
          exit! true
        end

        opts.on_tail("-v",
                     "--version",
                     "Show version") do
          puts Onevmcatcher::VERSION
          exit! true
        end
      end

      begin
        opts.parse!(args)
      rescue => ex
        puts ex.message.capitalize
        puts opts
        exit!
      end

      options
    end

    private

    def self.set_defaults(options)
      options.debug = false

      options.log = {}
      options.log.out = STDERR
      options.log.level = Onevmcatcher::Log::ERROR

      options.endpoint = "http://localhost:2633/RPC2"
      options.metadata_dir = "/var/spool/onevmcatcher"
      options.datastore = "opennebula"
      options.timeout = nil

      options.auth = {}
      options.auth.type = "none"
      options.auth.ca_path = "/etc/grid-security/certificates"
      options.auth.username = "anonymous"
      options.auth.ca_file = nil

      options
    end

  end
end
