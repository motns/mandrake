require 'simplecov'
SimpleCov.start do
  add_filter "spec/"
  add_filter "vendor/"
  add_group "Components", "lib/mandrake/components"
  add_group "Types", "lib/mandrake/type"
  add_group "Validators", "lib/mandrake/validator"
end

require 'mandrake'

class TestBaseModel
  include Mandrake::Model

  def self.model_name
    ActiveModel::Name.new(self, nil, "temp")
  end
end