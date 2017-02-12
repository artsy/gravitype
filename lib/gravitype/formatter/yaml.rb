require "yaml"
require "gravitype/formatter/dsl"

module Gravitype
  module Formatter
    module YAML
      def self.dump(introspections, output)
        introspections.each do |model, model_introspections|
          output.puts "#{model}:"
          model_introspections.each do |introspection, fields|
            output.puts "  #{introspection}:"
            fields.each do |field|
              output.puts "    #{field.name}: #{field.type.to_dsl}"
            end
            output.puts
          end
        end
        output
      end
    end
  end
end
