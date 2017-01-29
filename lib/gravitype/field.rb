require "gravitype/type"

module Gravitype
  class Field
    attr_reader :name, :type

    def initialize(name, type)
      @name, @type = name, type
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
  end
end
