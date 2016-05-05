# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'itchy/version'

Gem::Specification.new do |gem|
  gem.name          = 'itchy'
  gem.version       = Itchy::VERSION
  gem.authors       = ['Lubomir Kosaristan', 'Boris Parak']
  gem.email         = ['436322@mail.muni.cz', 'parak@cesnet.cz']
  gem.description   = 'Handler integrating nifty with vmcatcher (HEPIX)'
  gem.summary       = 'Event handler for vmcatcher'
  gem.homepage      = 'https://github.com/kosoburak/itchy'
  gem.license       = 'Apache License, Version 2.0'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  gem.require_paths = ['lib']

  gem.add_dependency 'opennebula', '~> 4.4', '>= 4.4.0'
  gem.add_dependency 'multi_json', '~> 1.10', '>= 1.10.1'
  gem.add_dependency 'mixlib-shellout', '~> 1.6', '>= 1.6.0'
  gem.add_dependency 'ox', '~> 2.1', '>= 2.1.3'
  gem.add_dependency 'oj', '~> 2.10', '>= 2.10.4'
  gem.add_dependency 'activesupport', '~> 4.0', '>= 4.0.0'
  gem.add_dependency 'settingslogic', '~> 2.0', '>= 2.0.9'
  gem.add_dependency 'hashie', '~> 3.3', '>= 3.3.1'
  gem.add_dependency 'thor', '~> 0.19', '>= 0.19.1'
  gem.add_dependency 'cloud-appliance-descriptor', '~> 0.2'
  gem.add_dependency 'nokogiri', '~>1.6', '>= 1.6.8'

  gem.add_development_dependency 'bundler', '~> 1.6'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 3.3.0'
  gem.add_development_dependency 'simplecov', '~> 0.10.0'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2.4'
  gem.add_development_dependency 'rubocop', '~> 0.32'

  gem.required_ruby_version = '>= 1.9.3'
end
