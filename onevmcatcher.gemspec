# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'onevmcatcher/version'

Gem::Specification.new do |gem|
  gem.name          = "onevmcatcher"
  gem.version       = Onevmcatcher::VERSION
  gem.authors       = ["Boris Parak"]
  gem.email         = ['parak@cesnet.cz']
  gem.description   = %q{Handler integrating OpenNebula with vmcatcher (HEPIX)}
  gem.summary       = %q{OpenNebula handler for vmcatcher}
  gem.homepage      = 'https://github.com/arax/onevmcatcher'
  gem.license       = 'Apache License, Version 2.0'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  gem.require_paths = ['lib']

  gem.add_dependency 'opennebula', '~> 4.4', '>= 4.4.0'
  gem.add_dependency 'json', '~> 1.8', '>= 1.8.1'
  gem.add_dependency 'mixlib-shellout', '~> 1.6', '>= 1.6.0'

  gem.required_ruby_version = ">= 1.9.3"
end
