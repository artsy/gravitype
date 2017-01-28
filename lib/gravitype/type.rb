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

    def eql?(other)
      type == other.type
    end

    def hash
      type.hash
    end

    class List < Type
      attr_reader :storage

      def initialize(object = nil)
        @storage = new_storage
        load_from_object(object) if object
      end

      def eql?(other)
        super && @storage == other.storage
      end

      def hash
        [super, @storage].hash
      end

      private

      def new_storage
        { values: ::Set.new }
      end

      def load_from_object(object)
        object.each do |value|
          @storage[:values] << Type.of(value)
        end
      end
    end

    class Array < List
      def type
        ::Array
      end
    end

    class Set < List
      def type
        ::Set
      end
    end

    class Hash < List
      def type
        ::Hash
      end

      private

      def new_storage
        super.merge(keys: ::Set.new)
      end

      def load_from_object(hash)
        hash.each do |key, value|
          @storage[:keys] << Type.of(key)
          @storage[:values] << Type.of(value)
        end
      end
    end
  end
end
