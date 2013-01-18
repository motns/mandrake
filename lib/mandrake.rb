require 'active_support/core_ext/class'
require 'active_support/concern'

require 'active_model/naming'
require 'active_model/translation'
require 'active_model/validations'

require 'mongo'
require 'logger'

# Components
require 'mandrake/keys'
require 'mandrake/dirty'
require 'mandrake/validations'

require 'mandrake/key'
require 'mandrake/type/base'
require 'mandrake/type/numeric'
require 'mandrake/type/integer'
require 'mandrake/type/string'

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