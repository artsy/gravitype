require "test_helper"

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
      result = @model.merged[:merged]
      result[:ruby_method].type.must_equal String!
      result[:mongoid_hash].type.must_equal Hash?(String! => Fixnum!)
      result[:mongoid_array].type.must_equal Array?(String!)
      result[:mongoid_set].type.must_equal Set!(String!)
      result[:mongoid_string].type.must_equal String!
      result[:mongoid_time].type.must_equal Time?
    end

    it "returns all introspections" do
      @model.introspect.keys.must_equal([
        :mongoid_schema,
        :mongoid_data,
        :all_json_fields,
        :public_json_fields,
        :short_json_fields,
        :merged,
      ])
    end
  end
end
