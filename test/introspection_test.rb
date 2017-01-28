require "test_helper"

describe Gravitype::Introspection do
  # it "returns a list of exposed JSON fields and their model getters" do
  #   Gravitype::Introspection.new(TestDoc).exposed_fields_and_getters.must_equal({
  #     mongoid_string: :mongoid_string,
  #     ruby_method: :ruby_method?,
  #   })
  # end
end

class Gravitype::Introspection
  describe Model do
    before do
      TestDoc.create(mongoid_string: 'foo', mongoid_hash: { 'foo' => 42 })
      TestDoc.create(mongoid_string: 'foo', mongoid_array: ['foo'])
      TestDoc.create(mongoid_string: 'foo', mongoid_set: Set.new(['foo']))
      @model = Model.new(TestDoc)
    end

    it "merges the data and schema results" do
      result = @model.merge
      result[:mongoid_hash].must_equal(Set.new([NilClass, { Set.new([String]) => Set.new([Fixnum]) }]))
      result[:mongoid_array].must_equal(Set.new([NilClass, [String]]))
      result[:mongoid_set].must_equal(Set.new([Set.new([String])]))
      result[:mongoid_string].must_equal(Set.new([String]))
      result[:mongoid_time].must_equal(Set.new([NilClass, Time]))
    end

    it "introspects both data and schema" do
      @model.introspect.must_equal(
        data: Data.new(TestDoc).introspect,
        schema: Schema.new(TestDoc).introspect,
        merged: @model.merge,
      )
    end
  end
end
