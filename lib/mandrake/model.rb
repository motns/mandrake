require 'mandrake/component/dirty'
require 'mandrake/component/keys'

module Mandrake
  module Model
    extend ActiveSupport::Concern

    COMPONENTS = [
      Mandrake::Keys,
      Mandrake::Dirty
    ]


    included do |base|
      COMPONENTS.each do |component|
        base.send :include, component
      end
    end


    module ClassMethods
      def model_methods_module
        @model_methods_module ||= begin
          mod = Module.new
          include(mod)
          mod
        end
      end
    end


    attr :new_keys, :removed_keys

    def initialize(attrs = {})
      @attributes = {}

      # New fields to write on next save
      @new_keys = []
      # Fields to remove on next save
      @removed_keys = attrs.keys


      # List of keys with defaults to process after
      # the rest of the data has been loaded
      post_process_defaults = []


      # Load data
      keys.each do |k, v|
        if attrs.key? v[:alias] # Data should be stored under the alias...
          @attributes[k] = attrs[v[:alias]]
          @removed_keys.delete(v[:alias])
        elsif attrs.key? k # ...but may be stored under the full name
          @attributes[k] = attrs[k]

          # Force a re-save for this field
          #   this way we'll write the field under the alias, and remove the old
          #   key on the next save
          @new_keys << k
          @removed_keys.delete(k)
        else
          if v[:default]
            if v[:post_processed_default]
              post_process_defaults << k
            else
              @attributes[k] = v[:default]
            end
          else
            @attributes[k] = nil
          end

          @new_keys << k
        end
      end

      # Post-processing
      post_process_defaults.each do |k|
        if keys[k][:default].respond_to?(:call)
          @attributes[k] = keys[k][:default].call(self)
        end
      end
    end
  end
end