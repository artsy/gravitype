require "yaml"
require "stringio"
require "gravitype/serialization/dsl"

module Gravitype
  module Serialization
    module YAML
      def self.dump(introspections, io = nil)
        output = io || StringIO.new
        introspections.each do |model, model_introspections|
          output.puts "#{model}:"
          model_introspections.each do |introspection_type, fields|
            output.puts "  #{introspection_type}:"
            fields.each do |field|
              output.puts "    #{field.name}: #{field.type.to_dsl}"
            end
            output.puts
          end
        end
        if io == nil
          output.rewind
          output.read
        end
      end

      def self.load(yaml)
        dsl = Object.new
        dsl.extend(Type::DSL)
        ::YAML.load(yaml).inject({}) do |introspections, (model, model_introspections)|
          introspections[model] = model_introspections.inject({}) do |model_introspection, (introspection_type, introspection_fields)|
            model_introspection[introspection_type.to_sym] = introspection_fields.map do |field_name, field_type|
              Field.new(field_name, field_type.nil? ? Type.new(NilClass) : dsl.instance_eval(field_type))
            end
            model_introspection
          end
          introspections
        end
      end
    end
  end
end
