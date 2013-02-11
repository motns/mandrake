require 'active_support/time'
require 'mongo'
require 'logger'

# @TODO - these could be autoloaded

require 'mandrake/failed_validators'

require 'mandrake/key'
require 'mandrake/type/base'
require 'mandrake/type/boolean'
require 'mandrake/type/numeric'
require 'mandrake/type/decimal'
require 'mandrake/type/float'
require 'mandrake/type/integer'
require 'mandrake/type/string'

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

require 'mandrake/components/keys'
require 'mandrake/components/dirty'
require 'mandrake/components/validations'

require 'mandrake/model'


module Mandrake
  def self.logger
    return @logger if defined? @logger

    @logger = ::Logger.new($stdout)
    @logger.level = ::Logger::INFO
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end


  # Extract Hash-based parameters from a list of arguments
  def self.extract_params(*args)
    params = args.pop if args[-1].is_a?(::Hash)
    params ||= {}

    return args, params
  end
end