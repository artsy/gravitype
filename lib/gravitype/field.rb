require "gravitype/type"

module Gravitype
  class Field
    attr_reader :name, :type

    def initialize(name, type)
      @name, @type = name.to_sym, type
    end

    def merge!(other)
      raise TypeError, "Cannot merge anything but fields" unless other.is_a?(Field)
      raise ArgumentError, "Different field name" unless @name == other.name
      @type |= other.type
      self
    end

    def merge(other)
      Field.new(@name, @type).tap do |field|
        field.merge!(other)
      end
    end

    def normalize
      Field.new(@name, @type.normalize)
    end

    def ==(other)
      other.is_a?(Field) && @name == other.name && @type == other.type
    end

    def <=>(other)
      @name <=> other.name
    end

    def eql?(other)
      self == other
    end

    def hash
      [@name, @type].hash
    end

    def inspect
      "{ #{@name}: #{@type.inspect} }"
    end
  end
end
