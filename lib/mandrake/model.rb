require 'mandrake/component/keys'

module Mandrake
  module Model
    extend ActiveSupport::Concern

    COMPONENTS = [
      Mandrake::Keys
    ]

    included do |base|
      COMPONENTS.each do |component|
        base.send :include, component
      end


      # @TODO - move this into Mandrake::Document
      base.class_eval do
        key :id, BSON::ObjectId, :as => :_id
      end
    end
  end
end