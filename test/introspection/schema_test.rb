require "test_helper"

module Gravitype
  describe "Schema introspection of Mongoid backed fields" do
    it "collects the type info" do
      expected = Mongoid::Fields::TYPE_MAPPINGS.inject({}) do |hash, (name, type)|
        # TODO Does Mongoid know if this is nullable?
        field_name = "mongoid_#{name}".to_sym
        hash[field_name] = Field.new(field_name, Type.of(type))
        hash
      end
      expected[:ruby_method] = Field.new(:ruby_method, Type.new(Object))
      Gravitype::Introspection::Schema.new(TestDoc).introspect.must_equal(expected)
    end
  end
end
