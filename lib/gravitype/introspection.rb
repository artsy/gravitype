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
      end.values.map(&:normalize).extend(ResultSet)
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

      def data
        @data ||= Introspection::Data.new(@model).introspect(data_introspection_fields)
      end

      def schema
        @schema ||= Introspection::Schema.new(@model).introspect(mongoid_fields)
      end

      def merged
        @merged ||= Introspection.merge(data, schema)
      end

      def subset(group)
        fields = if group == :schema
                   mongoid_fields.keys
                 elsif match = group.to_s.match(/^(\w+)_json_fields$/)
                   json_fields(match[1]).keys
                 else
                   raise ArgumentError, "Unknown subset group: #{group}"
                 end
        merged.select { |field| fields.include?(field.name) }
      end

      def mongoid_fields
        fields = @model.fields.keys.map(&:to_sym)
        Hash[*fields.zip(fields).flatten]
      end

      def json_fields(properties = :all)
        @model.cached_json_field_defs[properties.to_sym].inject({}) do |fields, (field, options)|
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
