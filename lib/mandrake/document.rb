module Mandrake
  module Document
    extend ActiveSupport::Concern

    COMPONENTS = [
      Mandrake::Keys
    ]

    included do |base|
      COMPONENTS.each do |component|
        base.send :include, component
      end

      base.class_eval do
        key :id, BSON::ObjectId, :as => :_id
      end
    end
  end
end