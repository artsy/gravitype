require "gravitype/type"
require "gravitype/type/compound"

module Gravitype
  class Type
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
        { values: Compound.new }
      end

      def load_from_object(object)
        object.each do |value|
          @storage[:values].types << Type.of(value)
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
        super.merge(keys: Compound.new)
      end

      def load_from_object(hash)
        hash.each do |key, value|
          @storage[:keys].types << Type.of(key)
          @storage[:values].types << Type.of(value)
        end
      end
    end
  end
end
