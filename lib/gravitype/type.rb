module Gravitype
  class Type
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
        new(object)
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
      Union.new([self, other])
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
