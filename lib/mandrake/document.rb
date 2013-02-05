module Mandrake
  module Document
    def self.included(base)
      base.class_eval do
        key :id, BSON::ObjectId, :as => :_id
      end
    end
  end
end