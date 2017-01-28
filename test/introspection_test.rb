require "test_helper"

describe Gravitype::Introspection do
  it "returns a list of exposed JSON fields and their model getters" do
    Gravitype::Introspection.new(TestDoc).exposed_fields_and_getters.must_equal({
      mongoid_string: :mongoid_string,
      ruby_method: :ruby_method?,
    })
  end
end
