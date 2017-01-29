module Gravitype
  class Introspection
    def initialize(model)
      @model = model
    end

    def exposed_fields_and_getters
      @model.cached_json_field_defs[:all].inject({}) do |fields, (field, options)|
        fields[field] = options[:definition] || field
        fields
      end
    end

    def introspect
      raise NotImplementedError
    end
  end

  class Introspection
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
        { data: data, schema: schema, merged: merge }
      end

      def merge
        merged = {}
        merge_fields(data, merged)
        merge_fields(schema, merged)
        merged.map { |_, field| field.normalize }
      end

      private

      def data
        @data ||= Introspection::Data.new(@model).introspect
      end

      def schema
        @schema ||= Introspection::Schema.new(@model).introspect
      end

      def merge_fields(from, into)
        from.each do |field|
          name = field.name
          if into[name]
            into[name] = into[name].merge(field)
          else
            into[name] = field
          end
        end
      end
    end
  end
end

require "gravitype/introspection/data"
require "gravitype/introspection/schema"
