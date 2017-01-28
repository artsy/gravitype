require "gravitype/introspection/data"
require "gravitype/introspection/schema"

module Gravitype
  class Model
    def initialize(model)
      @model = model
    end

    def introspect
      { data: data, schema: schema }
    end

    private

    def data
      @data ||= Introspection::Data.new(@model).introspect
    end

    def schema
      @schema ||= Introspection::Schema.new(@model).introspect
    end
  end
end
