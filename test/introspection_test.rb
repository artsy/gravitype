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
      result[:ruby_method].type.must_equal String!
      result[:mongoid_hash].type.must_equal Hash?(String! => Fixnum!)
      result[:mongoid_array].type.must_equal Array?(String!)
      result[:mongoid_set].type.must_equal Set!(String!)
      result[:mongoid_string].type.must_equal String!
      result[:mongoid_time].type.must_equal Time?
    end

    describe "subsets of merged fields" do
      it "scopes fields to only those that exist in the schema" do
        subset = @model.merged.dup
        subset.delete_field(:ruby_method)
        @model.subset(:schema).must_equal subset
      end

      it "scopes fields to only those that exist in `json_fields :all`" do
        @model.subset(:all_json_fields).sort.must_equal([
          @model.merged[:ruby_method],
          @model.merged[:mongoid_string],
          @model.merged[:mongoid_array],
          @model.merged[:mongoid_hash],
        ].sort)
      end

      it "scopes fields to only those that exist in `json_fields :public`" do
        @model.subset(:public_json_fields).sort.must_equal([
          @model.merged[:ruby_method],
          @model.merged[:mongoid_string],
          @model.merged[:mongoid_array],
        ].sort)
      end

      it "scopes fields to only those that exist in `json_fields :short`" do
        @model.subset(:short_json_fields).sort.must_equal([
          @model.merged[:ruby_method],
          @model.merged[:mongoid_string],
        ].sort)
      end
    end
  end
end
