require 'simplecov'
SimpleCov.start do
  add_filter "spec/"
end

require 'mandrake'

class TestBaseModel
  include Mandrake::Model
end