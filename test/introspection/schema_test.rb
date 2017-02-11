require "test_helper"

module Gravitype
  class Introspection
    describe "Schema introspection of Mongoid backed fields" do
      it "collects the type info" do
        expected = Mongoid::Fields::TYPE_MAPPINGS.map do |name, type|
          # TODO Does Mongoid know if this is nullable?
          Field.new("mongoid_#{name}".to_sym, Type.of(type))
        end
        Schema.new(TestDoc).introspect(expected.map(&:name)).must_equal(expected)
      end
    end
  end
end
