require "gravitype/introspection"

module Gravitype
  class Introspection
    # Collects type information from the schema (as defined by `json_fields`.)
    class Schema < Introspection
      def introspect(fields_with_getters = exposed_fields_and_getters)
        fields_with_getters.map do |name, _|
          # Default type, used when e.g. a field is not a mongo field but a Ruby method
          type = Object
          if mongo_field = @model.fields[name.to_s]
            type = mongo_field.type
          end
          Field.new(name.to_sym, Type.of(type))
        end
      end
    end
  end
end
