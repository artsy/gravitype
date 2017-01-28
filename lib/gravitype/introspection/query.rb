require "gravitype/introspection"
require "rubygems/version"

module Gravitype
  class Introspection
    # Collects type information from the schema (as defined by `json_fields`.)
    class Query < Introspection
      def introspect(fields_with_getters = exposed_fields_and_getters)
        if db_supports_type_aggregation?
          fields = fields_with_getters.keys
          if result = query_types(fields)
            fields.inject({}) do |hash, field|
              hash[field.to_sym] = result[field].to_sym
              hash
            end
          end
        end
      end

      private

      REQUIRED_MONGODB_VERSION = Gem::Version.new("3.4")

      def db_supports_type_aggregation?
        version = @model.collection.database.command(
          "$eval" => "function () { return db.version() }",
          nolock: true
        ).documents.first[:retval]
        Gem::Version.new(version) >= REQUIRED_MONGODB_VERSION
      end

      def query_types(fields)
        x = @model.collection.aggregate([{
          "$project" => fields.inject({}) do |hash, field_name|
            hash[field_name] = { "$type" => "$#{field_name}" }
            hash
          end
        }])
        p x.to_a
        x.first
      end
    end
  end
end
