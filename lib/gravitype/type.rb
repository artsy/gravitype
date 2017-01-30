require "mongoid"

module Gravitype
  class Type
    SCALAR_TYPES = {
      # Default wildcard: ‘any’
      "Object" => Object,
      # Mongoid specific
      "Boolean" => ::Mongoid::Boolean,
      # Mongo specific
      "ObjectId" => BSON::ObjectId,
      "Binary" => BSON::Binary,
      # Others from Mongoid::Fields::TYPE_MAPPINGS
      "Time" => Time,
      "Symbol" => Symbol,
      "String" => String,
      "Regexp" => BSON::Regexp::Raw,
      "Range" => Range,
      "Integer" => Integer,
      "Float" => Float,
      "DateTime" => DateTime,
      "Date" => Date,
      "BigDecimal" => BigDecimal,
    }.freeze

    SPECIAL_TYPES = SCALAR_TYPES.inject({}) do |hash, (name, klass)|
      if klass.name.include?("::")
        hash[klass] = name
      end
      hash
    end.freeze

    def self.of(object)
      case object
      when Type
        object
      when ::Hash
        Hash.new(object)
      when ::Array
        Array.new(object)
      when ::Set
        Set.new(object)
      when Class
        if object == ::Hash
          Hash.new
        elsif object == ::Array
          Array.new
        elsif object == ::Set
          Set.new
        else
          new(object)
        end
      else
        new(object.class)
      end
    end

    attr_reader :type

    def initialize(type)
      @type = type
    end

    # This makes Type and Type::Union duck-typable
    def types
      ::Set.new([self])
    end

    def ==(other)
      other.is_a?(Type) && type == other.type
    end

    def eql?(other)
      self == other
    end

    def hash
      type.hash
    end

    def |(other)
      raise TypeError, "Can only make a union of Type and subclasses of Type" unless other.is_a?(Type)
      other.is_a?(Union) ? (other | self) : Union.new([self, other])
    end

    def nullable?
      types.any? { |type| type.type == NilClass }
    end

    def normalize
      self
    end

    def inspect
      "#<Type:#{type}>"
    end
  end
end

require "gravitype/type/union"
require "gravitype/type/list"
require "gravitype/type/dsl"
