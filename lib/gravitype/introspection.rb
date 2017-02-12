require "parallel"

module Gravitype
  class Introspection
    def initialize(model)
      @model = model
    end

    def introspect
      raise NotImplementedError
    end
  end

  class Introspection
    def self.merge(*introspections)
      introspections.inject({}) do |merged, introspection|
        introspection.each do |field|
          name = field.name
          if merged[name]
            merged[name] = merged[name].merge(field)
          else
            merged[name] = field
          end
        end
        merged
      end.values.sort.map(&:normalize).extend(ResultSet)
    end

    def self.introspect(*models)
      if models.empty?
        models = Mongoid.models.select { |model| model.try(:cached_json_field_defs) }
      end
      Parallel.map(models) do |model|
        { model.name => Model.new(model).introspect }
      end.inject({}) { |result, introspection| result.merge(introspection) }
    end

    # Used to extend introspection results, which are arrays, for easy access by field name.
    module ResultSet
      def [](field_or_index)
        if field_or_index.is_a?(Symbol)
          find { |field| field.name == field_or_index }
        else
          super
        end
      end

      def delete_field(name)
        delete_if { |field| field.name == name }
      end

      def dup
        super.extend(ResultSet)
      end

      def select
        super.extend(ResultSet)
      end
    end

    class Model
      def initialize(model)
        @model = model
      end

      def schema
        @schema ||= Schema.new(@model).introspect
      end

      def data
        @data ||= Data.new(@model).introspect
      end

      def merged
        {
          merged: Introspection.merge(schema[:mongoid_schema], *data.values)
        }
      end

      def introspect
        schema.merge(data).merge(merged)
      end
    end
  end
end

require "gravitype/introspection/data"
require "gravitype/introspection/schema"
