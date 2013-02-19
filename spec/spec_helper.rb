require 'simplecov'
SimpleCov.start do
  add_filter "spec/"
  add_group "Components", "lib/mandrake/components"
  add_group "Types", "lib/mandrake/type"
  add_group "Validators", "lib/mandrake/validator"
end

require 'mandrake'

class TestBaseModel
  include Mandrake::Model
end