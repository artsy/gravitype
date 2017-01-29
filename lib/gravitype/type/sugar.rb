require "mongoid"

module Gravitype
  class Type
    module Sugar
      SCALAR_TYPES = {
        # Default wildcard: ‘any’
        "Object" => Object,
        # Mongoid specific
        "Boolean" => Mongoid::Boolean,
        # Mongo specific
        "ObjectId" => BSON::ObjectId,
        "Binary" => BSON::Binary,
        # Others from Mongoid::Fields::TYPE_MAPPINGS
        "Time" => Time,
        "Symbol" => Symbol,
        "String" => String,
        "Regexp" => Regexp,
        "Range" => Range,
        "Integer" => Integer,
        "Float" => Float,
        "DateTime" => DateTime,
        "Date" => Date,
        "BigDecimal" => BigDecimal,
      }.freeze

      SCALAR_TYPES.each do |name, klass|
        define_method("#{name}!") { Type.new(klass) }
        define_method("#{name}?") { Type.new(klass) | null }
      end

      def null
        Type.new(NilClass)
      end

      def Hash!(types = {})
        Type::Hash.new(types)
      end

      def Hash?(types = {})
        Hash!(types) | null
      end

      def Set!(*types)
        Type::Set.new(*types)
      end

      def Set?(*types)
        Set!(*types) | null
      end

      def Array!(*types)
        Type::Array.new(types)
      end

      def Array?(*types)
        Array!(*types) | null
      end
    end
  end
end
