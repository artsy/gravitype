require "gravitype/type"

module Gravitype
  class Type
    class Union < Type
      attr_reader :types

      def initialize(types = [])
        raise TypeError, "Requires an array of types" unless types.is_a?(::Array)
        @types = ::Set.new(types.map { |type| Type.of(type) })
      end

      def prominent_type
        copy = types.dup
        copy.delete_if { |type| type.type == NilClass }
        copy.first if copy.size == 1
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

      def normalize(unwrap_single_type = true)
        normalized = Union.new
        types = self.types.dup

        arrays = types.select { |type| type.type == ::Array }
        unless arrays.empty?
          types -= arrays
          normalized |= Array.new(arrays.map(&:values).reduce(:|).types.to_a).normalize
        end

        sets = types.select { |type| type.type == ::Set }
        unless sets.empty?
          types -= sets
          normalized |= Set.new(::Set.new(sets.map(&:values).reduce(:|).types.to_a)).normalize
        end

        hashes = types.select { |type| type.type == ::Hash }
        unless hashes.empty?
          types -= hashes
          hash = Hash.new
          hash.keys |= hashes.map(&:keys).reduce(:|)
          hash.values |= hashes.map(&:values).reduce(:|)
          normalized |= hash.normalize
        end

        # Add remainder
        types.each { |type| normalized |= type.normalize }
        # If there’s only 1 type, unwrap it from the union type.
        normalized = normalized.types.first if unwrap_single_type && normalized.types.size == 1

        normalized
      end

      def inspect
        "#<Type:Union [#{@types.map(&:inspect).join(", ")}]>"
      end
    end
  end
end
