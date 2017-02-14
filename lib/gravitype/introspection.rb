module Gravitype
  class Introspection
    def initialize(criteria)
      @criteria = criteria
    end

    def model
      @criteria.all.klass
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
      Batch.map(models) do |batch|
        [batch.model.name, batch.introspect]
      end.inject({}) do |batch_introspections, (model_name, batch_introspection)|
        if other = batch_introspections[model_name]
          batch_introspections[model_name] = Batch.merge(other, batch_introspection)
        else
          batch_introspections[model_name] = batch_introspection
        end
        batch_introspections
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
  end
end

require "gravitype/introspection/batch"
require "gravitype/introspection/data"
require "gravitype/introspection/schema"
