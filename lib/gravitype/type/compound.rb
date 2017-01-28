require "gravitype/type"

module Gravitype
  class Type
    class Compound < Type
      attr_reader :types

      def initialize(*types)
        @types = ::Set.new(types.flatten)
      end

      def ==(other)
        other.is_a?(Compound) && @types == other.types
      end

      def hash
        @types.hash
      end

      def +(other)
        raise TypeError, "Can only sum Type and subclasses of Type" unless other.is_a?(Type)
        Compound.new((types + other.types).to_a)
      end
    end
  end
end
