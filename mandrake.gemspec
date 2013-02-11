# encoding: UTF-8
require 'rake'
require File.expand_path('../lib/mandrake/version', __FILE__)

Gem::Specification.new do |s|
  s.name               = 'mandrake'
  s.version            = Mandrake::Version
  s.summary            = 'Another Ruby Object Mapper for Mongo'
  s.require_path       = 'lib'
  s.authors            = ['Adam Borocz']
  s.email              = ['adam@hipsnip.com']
  s.platform           = Gem::Platform::RUBY
  s.files              = FileList['lib/**/*.rb'].to_a

  s.add_dependency 'mongo', '~> 1.7.0'
  s.add_dependency 'bson_ext', '~> 1.7.0'
  s.add_dependency 'activesupport', '~> 3.2.12'
end