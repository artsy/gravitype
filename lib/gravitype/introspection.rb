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
      end.values.map(&:normalize)
    end

    def self.introspect(*models)
      if models.empty?
        models = Mongoid.models.select { |model| model.try(:cached_json_field_defs) }
      end
      models.inject({}) do |hash, model|
        hash[model.name] = Model.new(model).introspect
        hash
      end
    end

    class Model
      def initialize(model)
        @model = model
      end

      def introspect
        { data: data, schema: schema, merged: merged }
      end

      def data
        @data ||= Introspection::Data.new(@model).introspect(data_introspection_fields)
      end

      def schema
        @schema ||= Introspection::Schema.new(@model).introspect(mongoid_fields)
      end

      def merged
        @merged ||= Introspection.merge(data, schema)
      end

      def mongoid_fields
        fields = @model.fields.keys.map(&:to_sym)
        Hash[*fields.zip(fields).flatten]
      end

      def json_fields
        @model.cached_json_field_defs[:all].inject({}) do |fields, (field, options)|
          fields[field] = options[:definition] || field
          fields
        end
      end

      def data_introspection_fields
        mongoid_fields.merge(json_fields)
      end
    end
  end
end

require "gravitype/introspection/data"
require "gravitype/introspection/schema"
