require 'active_support/concern'
require 'mongo'
require 'logger'

require 'mandrake/keys'
require 'mandrake/document'

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