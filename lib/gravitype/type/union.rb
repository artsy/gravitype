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

      def normalize
        normalized = Union.new
        types = self.types.dup

        arrays = types.select { |type| type.type == ::Array }
        unless arrays.empty?
          types -= arrays
          normalized |= Array.new(arrays.map(&:values).reduce(:|).types.to_a)
        end

        sets = types.select { |type| type.type == ::Set }
        unless sets.empty?
          types -= sets
          normalized |= Set.new(sets.map(&:values).reduce(:|).types.to_a)
        end

        hashes = types.select { |type| type.type == ::Hash }
        unless hashes.empty?
          types -= hashes
          hash = Hash.new
          hash.keys |= hashes.map(&:keys).reduce(:|)
          hash.values |= hashes.map(&:values).reduce(:|)
          normalized |= hash
        end

        # Add remainder
        types.each { |type| normalized |= type }
        # If there’s only 1 type, unwrap it from the union type.
        normalized = normalized.types.first if normalized.types.size == 1

        normalized
      end

      def inspect
        "#<Type:Union [#{@types.map(&:inspect).join(", ")}]>"
      end
    end
  end
end
