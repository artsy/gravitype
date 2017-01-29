require "mongoid"

module Gravitype
  class Type
    def to_mongoid
      if type == TrueClass || type == FalseClass
        Type.new(::Mongoid::Boolean)
      elsif type == Fixnum
        Type.new(Integer)
      else
        self
      end
    end
  end

  class Type::Union
    def to_mongoid(unwrap_single_type = true)
      Union.new(types.map(&:to_mongoid)).normalize(unwrap_single_type)
    end
  end

  class Type::List
    def to_mongoid
      self.class.new.tap do |copy|
        copy.values = values.to_mongoid(false)
      end
    end
  end

  class Type::Hash
    def to_mongoid
      super.tap do |copy|
        copy.keys = keys.to_mongoid(false)
      end
    end
  end

  module Transformer
    module Mongoid
      def self.transform_field(field)
        Field.new(field.name, field.type.to_mongoid)
      end

      def self.transform(fields)
        fields.map { |field| transform_field(field) }
      end
    end
  end
end
