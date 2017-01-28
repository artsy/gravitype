require "gravitype/type"
require "gravitype/type/compound"

module Gravitype
  class Type
    class List < Type
      attr_reader :storage

      def initialize(*objects)
        @storage = new_storage
        load_from_objects(objects)
      end

      def values
        @storage[:values]
      end

      def values=(values)
        @storage[:values] = values
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

      def load_from_objects(objects)
        objects.each do |object|
          if object.is_a?(type)
            load_from_list_object(object)
          else
            load_from_object(object)
          end
        end
      end

      def load_from_list_object(list)
        list.each { |object| load_from_object(object) }
      end

      def load_from_object(object, storage_key = :values)
        @storage[storage_key].types << Type.of(object)
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

      def keys
        @storage[:keys]
      end

      def keys=(keys)
        @storage[:keys] = keys
      end

      private

      def new_storage
        super.merge(keys: Compound.new)
      end

      def load_from_list_object(hash)
        hash.each do |key, value|
          load_from_object(key, :keys)
          load_from_object(value, :values)
        end
      end
    end
  end
end
