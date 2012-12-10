class User
  include Mandrake::Document

  # For automatic timestamps
  # Create/maintain created_at, updated_at
  Mandrake::Timestamps


  # Optional override for storage collection
  # Defaults to pluralised name of Model class
  collection 'users'


  # Key name and type are required
  # Keep types as Ruby object types
  key :name, String, as: 'n', required: true
  # non-required, with default - if no default is set for a field, it's set to Nil
  key :description, String, :as => 'd', :required => false, :default => '', :length => 500
  # username
  key :username, String, \
    :as => 'un', :required => true, \
    :length => 2..20, :unique => true, \
    :format => /[a-zA-Z0-9\_]+/, \
    :default => ->{ self.name.downcase.gsub(/ /, '') } # Accept lambdas - self refers to current Model instance
  key :email, String, :as => 'e', :required => true, :unique => true, :email => true # Uses email validator Gem


  # Relationships defined manually
  def self.trips
    Trip.find(:user_id => seld._id).sort(:created_at => :desc)
  end


  # A limited subset of parent Model
  class Summary
    include Mandrake::View

    include_keys :name, :username
    # OR
    exclude_keys :password, :email
    # can't be both!

    # can define its own scope - overrides parent's
    default_scope # criteria
  end
end