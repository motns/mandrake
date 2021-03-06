# encoding: UTF-8
require File.expand_path('../lib/mandrake/version', __FILE__)

Gem::Specification.new do |s|
  s.name                   = 'mandrake'
  s.version                = Mandrake::Version
  s.summary                = 'Another Ruby Object Mapper for Mongo'
  s.require_path           = 'lib'
  s.authors                = ['Adam Borocz']
  s.email                  = ['adam@hipsnip.com']
  s.platform               = Gem::Platform::RUBY
  s.files                  = Dir.glob('lib/**/*.rb')
  s.required_ruby_version  = '>= 1.9.3'

  s.add_dependency 'mongo', '~> 1.8.3'
  s.add_dependency 'bson_ext', '~> 1.8.3'
  s.add_dependency 'activesupport', '~> 3.2.12'
  s.add_dependency 'activemodel', '~> 3.2.12'
end