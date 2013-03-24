module Mandrake
  # A wrapper around {Mandrake::Model}, used to represent a MongoDB document
  module Document
    extend ActiveSupport::Concern

    COMPONENTS = [
      Mandrake::Model,
      Mandrake::Relations
    ]

    included do |base|
      COMPONENTS.each do |component|
        base.send :include, component
      end

      base.class_eval do
        key :id, :ObjectId, :as => :_id
      end
    end
  end
end