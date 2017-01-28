require "gravitype/Introspection"

module Gravitype
  class Introspection
    # Collects type information from the schema (as defined by `json_fields`.)
    class Schema < Introspection
      def introspect(fields_with_getters = exposed_fields_and_getters)
        fields_with_getters.inject({}) do |hash, (field_name, _)|
          if field = @model.fields[field_name.to_s]
            hash[field_name.to_sym] = Set.new([field.type])
          else
            # A Ruby method, not a DB field
            # TODO any?
            hash[field_name.to_sym] = Set.new([Object])
          end
          hash
        end
      end
    end
  end
end
