module Onevmcatcher
  class Settings < Settingslogic
    HOME_CONF   = File.join(
      ENV['HOME'],
      '.onevmcatcher.yml'
    )
    GLOBAL_CONF = File.join(
      "#{File::SEPARATOR}etc",
      'onevmcatcher',
      'onevmcatcher.yml'
    )
    GEM_CONF    = File.join(
      File.expand_path(File.join('..', '..', '..'), __FILE__),
      'config',
      'onevmcatcher.yml'
    )

    source HOME_CONF if File.readable? HOME_CONF
    source GLOBAL_CONF if File.readable? GLOBAL_CONF
    source GEM_CONF

    load!
  end
end
