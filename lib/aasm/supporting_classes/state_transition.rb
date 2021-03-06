module AASM
  module SupportingClasses
    class StateTransition
      attr_reader :from, :to, :opts
      alias_method :options, :opts

      def initialize(opts)
        @from, @to, @guard, @on_transition = opts[:from], opts[:to], opts[:guard], opts[:on_transition]
        @opts = opts
      end

      # TODO: should be named allowed? or similar
      def perform(obj, *args)
        case @guard
          when Symbol, String
            obj.send(@guard, *args)
          when Proc
            @guard.call(obj, *args)
          else
            true
        end
      end

      def execute(obj, *args)
        @on_transition.is_a?(Array) ?
                @on_transition.each {|ot| _execute(obj, ot, *args)} :
                _execute(obj, @on_transition, *args)
      end

      def ==(obj)
        @from == obj.from && @to == obj.to
      end

      def from?(value)
        @from == value
      end

      private

      def _execute(obj, on_transition, *args)
        case on_transition
        when Proc
          on_transition.arity == 0 ? on_transition.call : on_transition.call(obj, *args)
        when Symbol, String
          obj.send(:method, on_transition.to_sym).arity == 0 ? obj.send(on_transition) : obj.send(on_transition, *args)
        end
      end

    end
  end # SupportingClasses
end # AASM
