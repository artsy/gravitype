require "gravitype/introspection/data"
require "gravitype/introspection/schema"

module Gravitype
  def self.introspect(*models)
    if models.empty?
      models = Mongoid.models.select { |model| model.try(:cached_json_field_defs) }
    end
    models.inject({}) do |hash, model|
      hash[model.name] = Model.new(model).introspect
      hash
    end
  end

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
