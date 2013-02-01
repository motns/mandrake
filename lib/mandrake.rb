require 'active_support/concern'

require 'mongo'
require 'logger'

require 'mandrake/components/keys'
require 'mandrake/components/dirty'
require 'mandrake/components/validations'

require 'mandrake/key'
require 'mandrake/type/base'
require 'mandrake/type/boolean'
require 'mandrake/type/numeric'
require 'mandrake/type/decimal'
require 'mandrake/type/float'
require 'mandrake/type/integer'
require 'mandrake/type/string'

require 'mandrake/validator/base'
require 'mandrake/validator/presence'
require 'mandrake/validator/length'

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
end