module Itchy
  # Wraps access to configuration files. Files are loaded
  # in the following order:
  #
  # 1.) ~/.itchy.yml
  # 2.) /etc/itchy/itchy.yml
  # 3.) GEM_INSTALL_DIR/config/itchy.yml
  #
  # The first available file will be used. Settings are never
  # merged from multiple files.
  class Settings < Settingslogic
    HOME_CONF = File.join(
      ENV['HOME'],
      '.itchy.yml'
    )
    GLOBAL_CONF = File.join(
      "#{File::SEPARATOR}etc",
      'itchy',
      'itchy.yml'
    )
    GEM_CONF = File.join(
      File.expand_path(File.join('..', '..', '..'), __FILE__),
      'config',
      'itchy.yml'
    )

    source HOME_CONF if File.readable? HOME_CONF
    source GLOBAL_CONF if File.readable? GLOBAL_CONF
    source GEM_CONF

    namespace ENV['RAILS_ENV'].blank? ? 'production' : ENV['RAILS_ENV']

    load!
  end
end
