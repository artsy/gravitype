require "gravitype/introspection"

module Gravitype
  class Introspection
    # Collects type information from the MongoDB schema.
    class Schema < Introspection
      def introspect(fields_with_getters)
        # Simplify testing by allowing an array of fields.
        fields = fields_with_getters.is_a?(Array) ? fields_with_getters : fields_with_getters.keys
        fields.map do |name|
          mongo_field = @model.fields[name.to_s]
          Field.new(name.to_sym, Type.of(mongo_field.type))
        end.extend(ResultSet)
      end
    end
  end
end
