module Gravitype
  class Type
    def self.of(object)
      case object
      when Class
        raise ArgumentError, "Do not use Type.of with classes"
      when ::Hash
        Hash.new(object)
      when ::Array
        Array.new(object)
      when ::Set
        Set.new(object)
      else
        new(object.class)
      end
    end

    attr_reader :type

    def initialize(type)
      @type = type
    end

    # This makes Type and Type::Compound duck-typable
    def types
      ::Set.new([self])
    end

    def eql?(other)
      type == other.type
    end

    def hash
      type.hash
    end

    def +(other)
      raise TypeError, "Can only sum Type and subclasses of Type" unless other.is_a?(Type)
      Compound.new(self, other)
    end

    def nullable?
      types.any? { |type| type.type == NilClass }
    end
  end
end

require "gravitype/type/compound"
require "gravitype/type/list"
