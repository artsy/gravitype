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
        result = Hash.new { |h,k| h[k] = Set.new }
        data.each do |field, classes|
          result[field].merge(classes)
        end
        schema.each do |field, classes|
          classes.each do |klass|
            # Prefer more detailed collection definitions
            if klass == Hash
              unless result[field].any? { |x| x.is_a?(Hash) }
                result[field] << Hash
              end
            elsif klass == Array
              unless result[field].any? { |x| x.is_a?(Array) }
                result[field] << Array
              end
            elsif klass == Set
              unless result[field].any? { |x| x.is_a?(Set) }
                result[field] << Set
              end
            else
              result[field] << klass
            end
          end
        end
        result
      end

      private

      def data
        @data ||= Introspection::Data.new(@model).introspect
      end

      def schema
        @schema ||= Introspection::Schema.new(@model).introspect
      end
    end
  end
end

require "gravitype/introspection/data"
require "gravitype/introspection/schema"
