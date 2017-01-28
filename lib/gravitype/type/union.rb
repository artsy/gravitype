require "gravitype/type"

module Gravitype
  class Type
    class Union < Type
      attr_reader :types

      def initialize(types = [])
        @types = ::Set.new(types.map { |type| Type.of(type) })
      end

      def ==(other)
        other.is_a?(Union) && @types == other.types
      end

      def hash
        @types.hash
      end

      def |(other)
        raise TypeError, "Can only make a union of Type and subclasses of Type" unless other.is_a?(Type)
        Union.new((types + other.types).to_a)
      end
    end
  end
end
