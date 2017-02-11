require "test_helper"

describe Gravitype::Introspection do
  # it "returns a list of exposed JSON fields and their model getters" do
  #   Gravitype::Introspection.new(TestDoc).exposed_fields_and_getters.must_equal({
  #     mongoid_string: :mongoid_string,
  #     ruby_method: :ruby_method?,
  #   })
  # end
end

module Gravitype
  describe Introspection::Model do
    include Type::DSL

    before do
      TestDoc.create(mongoid_string: 'foo', mongoid_hash: { 'foo' => 42 })
      TestDoc.create(mongoid_string: 'foo', mongoid_array: ['foo'])
      TestDoc.create(mongoid_string: 'foo', mongoid_set: Set.new(['foo']))
      @model = Introspection::Model.new(TestDoc)
    end

    it "returns the fields of the mongoid schema (getter is same as field)" do
      fields = @model.mongoid_fields
      fields.keys.must_equal TestDoc.fields.keys.map(&:to_sym)
      fields.values.must_equal fields.keys
    end

    it "returns the fields exposed through `json_fields`" do
      @model.json_fields.must_equal({
        ruby_method: :ruby_method?,
        mongoid_string: :mongoid_string,
        mongoid_array: :mongoid_array,
        mongoid_hash: :mongoid_hash,
      })
    end

    it "returns a union of mongoid schema and json_fields fields to introspect data of" do
      @model.data_introspection_fields.must_equal @model.mongoid_fields.merge(@model.json_fields)
    end

    it "merges the data and schema results" do
      result = @model.merged
      field(result, :mongoid_hash).type.must_equal Hash?(String! => Fixnum!)
      field(result, :mongoid_array).type.must_equal Array?(String!)
      field(result, :mongoid_set).type.must_equal Set!(String!)
      field(result, :mongoid_string).type.must_equal String!
      field(result, :mongoid_time).type.must_equal Time?
    end

    it "introspects both data and schema" do
      data = Introspection::Data.new(TestDoc).introspect(@model.data_introspection_fields)
      schema = Introspection::Schema.new(TestDoc).introspect(@model.mongoid_fields)
      @model.introspect.must_equal(
        data: data,
        schema: schema,
        merged: Introspection.merge(data, schema),
      )
    end

    private

    def field(result, name)
      result.find { |field| field.name == name }
    end
  end
end
