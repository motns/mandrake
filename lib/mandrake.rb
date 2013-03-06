require 'active_support/callbacks'
require 'active_support/time'
require 'mongo'
require 'logger'

require 'mandrake/failed_validators'

require 'mandrake/key'
require 'mandrake/type/base'
require 'mandrake/type/boolean'
require 'mandrake/type/numeric'
require 'mandrake/type/decimal'
require 'mandrake/type/float'
require 'mandrake/type/integer'
require 'mandrake/type/string'
require 'mandrake/type/collection'
require 'mandrake/type/array'
require 'mandrake/type/set'
require 'mandrake/type/time'

require 'mandrake/validator/base'
require 'mandrake/validator/absence'
require 'mandrake/validator/presence'
require 'mandrake/validator/length'
require 'mandrake/validator/format'
require 'mandrake/validator/exclusion'
require 'mandrake/validator/inclusion'
require 'mandrake/validator/value_match'

require 'mandrake/validation'
require 'mandrake/validation_chain'

require 'mandrake/components/callbacks'
require 'mandrake/components/keys'
require 'mandrake/components/dirty'
require 'mandrake/components/validations'

require 'mandrake/model'


# The top-level namespace for our magnificent library. Contains a few helpers,
# and a base logging facility.
module Mandrake

  # Return the current logger instance
  #
  # @return [Logger]
  def self.logger
    return @logger if defined? @logger

    @logger = ::Logger.new($stdout)
    @logger.level = ::Logger::INFO
    @logger
  end


  # Define an alternative logger to use
  #
  # @param [Logger] logger
  # @return [Logger]
  def self.logger=(logger)
    @logger = logger
  end


  # Used to extract Hash-based parameters from a list of arguments
  #
  # @example No parameters passed in
  #    Mandrake.extract_params(:one, :two) # => [:one, :two], {}
  #
  # @example Parameters Hash at the end
  #    Mandrake.extract_params(:one, :two, enable: true) # => [:one, :two], {:enable => true}
  #
  # @return [Array]
  # @return [Hash]
  def self.extract_params(*args)
    params = args.pop if args[-1].is_a?(::Hash)
    params ||= {}

    return args, params
  end
end