module Gravitype
  class Introspection
    def initialize(model)
      @model = model
    end

    def exposed_fields_and_getters
      @model.cached_json_field_defs[:all].inject({}) do |fields, (field, options)|
        fields[field] = options[:definition] || field
        fields
      end
    end

    def introspect
      raise NotImplementedError
    end
  end
end
