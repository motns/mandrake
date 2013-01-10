module Mandrake
  module Document
    extend ActiveSupport::Concern

    included do |base|
      base.class_eval do
        key :id, BSON::ObjectId, :as => :_id
      end
    end
  end
end