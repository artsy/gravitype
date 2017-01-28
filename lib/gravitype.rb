require "gravitype/field"
require "gravitype/introspection"
require "gravitype/type"

require "json"
require "mongoid"
require "mongoid-cached-json"

module Gravitype
  # Based on: Hash[*Mongoid::Fields::TYPE_MAPPINGS.to_a.flatten.reverse]
  MONGOID_TYPES = {
    Time => :time,
    Symbol => :symbol,
    String => :string,
    Set => :set,
    Regexp => :regexp,
    Range => :range,
    BSON::ObjectId => :object_id,
    Integer => :integer,
    Hash => :hash,
    Float => :float,
    DateTime => :date_time,
    Date => :date,
    Mongoid::Boolean => :boolean,
    BSON::Binary => :binary,
    BigDecimal => :big_decimal,
    Array => :array,
    # Additional
    Object => :any,
    NilClass => :null,
    TrueClass => :boolean,
    FalseClass => :boolean,
    Fixnum => :integer,
  }

  def self.pretty_json(introspection_result)
    transformed = introspection_result.inject({}) do |models, (model, introspection_types)|
      models[model] = introspection_types.inject({}) do |introspections, (introspection_type, field_sets)|
        introspections[introspection_type] = field_sets.inject({}) do |fields, (field, classes)|
          transformed_field = classes.to_a.map do |typings|
            case typings
            when Hash
              {
                keys: classes_to_types(typings.keys.first),
                values: classes_to_types(typings.values.first),
              }
            when Array
              classes_to_types(typings)
            else
              class_to_type(typings)
            end
          end
          transformed_field = transformed_field.first if transformed_field.size == 1
          fields[field] = transformed_field
          fields
        end
        introspections
      end
      models
    end
    JSON.pretty_generate(transformed)
  end

  def self.class_to_type(klass)
    MONGOID_TYPES[klass] || raise(TypeError, "Unknown type: #{klass}")
  end

  def self.classes_to_types(classes)
    classes.to_a.map { |klass| class_to_type(klass) }.uniq
  end
end
