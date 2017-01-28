require "test_helper"

module Gravitype
  describe Type do
    it "wraps a non-collection class" do
      Type.new(String).type.must_equal String
      Type.of('foo').type.must_equal String
    end

    it "automatically wraps classes as types when creating a union type" do
      Type::Union.new([Type.new(String), Type.new(Symbol)]).must_equal Type::Union.new([String, Symbol])
    end

    it "returns a union type" do
      type = Type.new(String) | Type.new(Symbol) | Type.new(String)
      type.must_equal Type::Union.new([Type.new(String), Type.new(Symbol)])
    end

    it "returns if it is nullable" do
      Type.new(NilClass).nullable?.must_equal true
      Type.new(String).nullable?.must_equal false
      Type::Union.new([Type.new(String)]).nullable?.must_equal false
      Type::Union.new([Type.new(NilClass), Type.new(String)]).nullable?.must_equal true
    end

    describe "list" do
      it "wraps a hash" do
        type = Type::Hash.new
        type.type.must_equal Hash
        type.storage[:keys].must_equal Type::Union.new
        type.storage[:values].must_equal Type::Union.new

        type = Type.of(:foo => "bar", "baz" => 42, :another => 21)
        type.type.must_equal Hash
        type.storage[:keys].must_equal Type::Union.new([Symbol, String])
        type.storage[:values].must_equal Type::Union.new([String, Fixnum])
      end

      it "wraps an array" do
        type = Type::Array.new
        type.type.must_equal Array
        type.storage[:values].must_equal Type::Union.new

        type = Type::Array.new(String)
        type.type.must_equal Array
        type.storage[:values].must_equal Type::Union.new([String])

        type = Type.of([:foo, "bar", 42, :another, 21])
        type.type.must_equal Array
        type.storage[:values].must_equal Type::Union.new([String, Symbol, Fixnum])
      end

      it "wraps a set" do
        type = Type::Set.new
        type.type.must_equal Set
        type.storage[:values].must_equal Type::Union.new

        type = Type::Set.new(String)
        type.type.must_equal Set
        type.storage[:values].must_equal Type::Union.new([String])

        type = Type.of(Set.new([:foo, "bar", 42, :another, 21]))
        type.type.must_equal Set
        type.storage[:values].must_equal Type::Union.new([String, Symbol, Fixnum])
      end
    end
  end
end
