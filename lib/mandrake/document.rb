module Mandrake
  # A wrapper around {Mandrake::Model}, used to represent a MongoDB document
  module Document
    # Adds a MongoDB object id to the current Model
    def self.included(base)
      base.class_eval do
        key :id, :ObjectId, :as => :_id
      end
    end
  end
end