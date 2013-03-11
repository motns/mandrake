module Mandrake
  # Used to create base life-cycle callbacks for Models - based on ActiveSupport::Callbacks
  module Callbacks
    extend ActiveSupport::Concern

    included do |base|
      base.send :include, ::ActiveSupport::Callbacks
      base.define_model_callbacks :initialize, :attribute_change, only: [:after]
    end


    # Methods to extend the class we're included in
    module ClassMethods
      # Helper method to define macros for creating new callback definitions.
      #
      # @example Create a new callback to run before and after an update
      #
      #    define_model_callbacks(:update, :only => [:before, :after])
      #    # shortcut for:
      #    set_callback(:update, :before, :terminator => "result == false", \
      #        :skip_after_callbacks_if_terminated => true, :scope => [:kind, :name])
      #    set_callback(:update, :after, :terminator => "result == false", \
      #        :skip_after_callbacks_if_terminated => true, :scope => [:kind, :name])
      #
      #
      # @overload define_model_callbacks(*events, *options)
      #   @param [Symbol] events A list of events we want to set up callbacks for
      #   @param [Hash] options See ActiveSupport::Callbacks#set_callback for all available options
      #   @option options [Array] :only ([:before, :around, :after]) The callback types to create
      #   @return [void]
      def define_model_callbacks(*args)
        events, options = Mandrake::extract_params(*args)

        events.each do |event|
          options = {
            :terminator => "result == false",
            :skip_after_callbacks_if_terminated => true,
            :scope => [:kind, :name],
            :only => [:before, :around, :after]
          }.merge!(options)

          define_callbacks event, options

          options[:only].each do |on|
            singleton_class.class_eval do
              define_method :"#{on}_#{event}" do |*args, &block|
                set_callback(event, on, *args, &block)
              end
            end
          end
        end
      end
    end
  end
end