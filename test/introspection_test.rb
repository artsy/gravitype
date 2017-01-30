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

    it "merges the data and schema results" do
      result = @model.merge
      field(result, :mongoid_hash).type.must_equal Hash?(String! => Fixnum!)
      field(result, :mongoid_array).type.must_equal Array?(String!)
      field(result, :mongoid_set).type.must_equal Set!(String!)
      field(result, :mongoid_string).type.must_equal String!
      field(result, :mongoid_time).type.must_equal Time?
    end

    it "introspects both data and schema" do
      @model.introspect.must_equal(
        data: Introspection::Data.new(TestDoc).introspect,
        schema: Introspection::Schema.new(TestDoc).introspect,
        merged: @model.merge,
      )
    end

    private

    def field(result, name)
      result.find { |field| field.name == name }
    end
  end
end
