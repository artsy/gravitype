require "test_helper"

describe Gravitype::Introspection::Query do
  it "uses a MongoDB query to get the types for each field" do
    TestDoc.create(mongoid_array: ['foo'])
    TestDoc.create(mongoid_string: 'foo')
    # TestDoc.create(mongoid_string: nil)
    TestDoc.create(mongoid_boolean: true)
    TestDoc.create(mongoid_big_decimal: BigDecimal.new("42"))
    result = Gravitype::Introspection::Query.new(TestDoc).introspect
    result.must_equal({
      mongoid_big_decimal: :float,
      mongoid_array: :array,
      mongoid_string: :string,
    })
    # expected = Mongoid::Fields::TYPE_MAPPINGS.inject({}) do |hash, (name, type)|
    #   # TODO Does Mongoid know if this is nullable?
    #   hash["mongoid_#{name}".to_sym] = Set.new([type])
    #   hash
    # end
    # expected[:ruby_method] = Set.new([Object])
    # Gravitype::Introspection::Query.new(TestDoc).introspect.must_equal(expected)
  end
end
