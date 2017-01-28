require "set"
require "active_support/core_ext/object/duplicable"

module Gravitype
  class Field
    attr_reader :name, :classes

    def initialize(name, classes = [])
      @name = name
      @classes = Set.new(classes)
    end

    def merge!(other)
      raise ArgumentError, "Cannot merge anything but fields" unless other.is_a?(Field)
      raise ArgumentError, "Different field name" unless @name == other.name
      @classes.merge(other.classes)
      self
    end

    def merge(other)
      Field.new(@name).tap do |field|
        field.merge!(self)
        field.merge!(other)
      end
    end

    def normalize
      field = Field.new(@name)
      @classes.each do |klass|
        # Prefer more detailed collection definitions
        if klass == Hash
          unless field.classes.any? { |x| x.is_a?(Hash) }
            field.classes << Hash
          end
        elsif klass == Array
          unless field.classes.any? { |x| x.is_a?(Array) }
            field.classes << Array
          end
        elsif klass == Set
          unless field.classes.any? { |x| x.is_a?(Set) }
            field.classes << Set
          end
        else
          field.classes << klass
        end
      end
      field
    end
  end
end
