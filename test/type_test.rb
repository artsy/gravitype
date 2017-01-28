require "test_helper"

module Gravitype
  describe Type do
    it "wraps a non-collection class" do
      Type.new(String).type.must_equal String
      Type.of('foo').type.must_equal String
    end

    it "wraps a hash" do
      type = Type::Hash.new
      type.type.must_equal Hash
      type.storage[:keys].must_equal Set.new
      type.storage[:values].must_equal Set.new

      type = Type.of(:foo => "bar", "baz" => 42, :another => 21)
      type.type.must_equal Hash
      type.storage[:keys].must_equal Set.new([Type.new(Symbol), Type.new(String)])
      type.storage[:values].must_equal Set.new([Type.new(String), Type.new(Fixnum)])
    end

    it "wraps an array" do
      type = Type::Array.new
      type.type.must_equal Array
      type.storage[:values].must_equal Set.new

      type = Type.of([:foo, "bar", 42, :another, 21])
      type.type.must_equal Array
      type.storage[:values].must_equal Set.new([Type.new(String), Type.new(Symbol), Type.new(Fixnum)])
    end

    it "wraps a set" do
      type = Type::Set.new
      type.type.must_equal Set
      type.storage[:values].must_equal Set.new

      type = Type.of(Set.new([:foo, "bar", 42, :another, 21]))
      type.type.must_equal Set
      type.storage[:values].must_equal Set.new([Type.new(String), Type.new(Symbol), Type.new(Fixnum)])
    end
  end
end
