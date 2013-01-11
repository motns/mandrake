require 'active_support/core_ext/class'
require 'active_support/concern'

require 'active_model/naming'
require 'active_model/translation'
require 'active_model/validations'

require 'mongo'
require 'logger'

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