require "gravitype/introspection"

module Gravitype
  class Introspection
    # Collects type information from the MongoDB schema.
    class Schema < Introspection
      def introspect
        @result ||= {
          mongoid_schema: model.fields.map do |name, field|
            Field.new(name.to_sym, Type.of(field.type))
          end.sort.extend(ResultSet)
        }
      end
    end
  end
end
