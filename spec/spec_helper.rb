require 'rubygems'

# enable coverage reports
if ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.add_filter '/spec/'
  SimpleCov.start
end

require 'itchy'
