require "test_helper"

describe "Schema introspection of Mongoid backed fields" do
  it "collects the type info" do
    expected = Mongoid::Fields::TYPE_MAPPINGS.inject({}) do |hash, (name, type)|
      # TODO Does Mongo know if this is nullable?
      hash["mongoid_#{name}".to_sym] = Set.new([type])
      hash
    end
    expected[:ruby_method] = Set.new([Object])
    Gravitype::Introspection::Schema.new(TestDoc).introspect.must_equal(expected)
  end
end
