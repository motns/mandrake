require 'simplecov'
SimpleCov.start do
  add_filter "spec/"
end

require 'mandrake'

class TestBaseModel
  include Mandrake::Model

  def self.model_name
    ActiveModel::Name.new(self, nil, "TestClass")
  end
end