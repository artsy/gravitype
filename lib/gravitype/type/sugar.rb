require "mongoid"

module Gravitype
  class Type
    module Sugar
      def self.define_scalar_type(name, klass)
        define_method("#{name}!") { Type.new(klass) }
        define_method("#{name}?") { Type.new(klass) | null }
      end

      Type::SCALAR_TYPES.each do |name, klass|
        define_scalar_type(name, klass)
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

      # TODO: It actually appears that mongo/mongoid does not return `null` for set fields.
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
