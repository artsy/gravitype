require "test_helper"

module Gravitype
  class Introspection
    describe Batch do
      include Type::DSL

      before do
        TestDoc.create(mongoid_string: 'foo', mongoid_hash: { 'foo' => 42 })
        TestDoc.create(mongoid_string: 'foo', mongoid_array: ['foo'])
        TestDoc.create(mongoid_string: 'foo', mongoid_set: Set.new(['foo']))
        @batch = Batch.new(TestDoc)
      end

      it "creates batches for the passed in models" do
        create_art_fixtures!
        Batch.create([TestDoc, Artwork], 1).map { |b| [b.model, b.criteria.options] }.must_equal([
          [TestDoc, skip: 0, limit: 1],
          [TestDoc, skip: 1, limit: 1],
          [TestDoc, skip: 2, limit: 1],
          [TestDoc, skip: 3, limit: 1],
          [Artwork, skip: 0, limit: 1],
          [Artwork, skip: 1, limit: 1],
          [Artwork, skip: 2, limit: 1],
        ])
      end

      it "merges the data and schema results" do
        result = @batch.merged[:merged]
        result[:ruby_method].type.must_equal String!
        result[:mongoid_hash].type.must_equal Hash?(String! => Fixnum!)
        result[:mongoid_array].type.must_equal Array?(String!)
        result[:mongoid_set].type.must_equal Set!(String!)
        result[:mongoid_string].type.must_equal String!
        result[:mongoid_time].type.must_equal Time?
      end

      it "returns all introspections" do
        @batch.introspect.keys.must_equal([
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
end
