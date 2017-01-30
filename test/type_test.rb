require "test_helper"

module Gravitype
  describe Type do
    it "wraps a non-collection class" do
      Type.new(String).type.must_equal String
      Type.of('foo').type.must_equal String
    end

    it "returns if it is nullable" do
      Type.new(NilClass).nullable?.must_equal true
      Type.new(String).nullable?.must_equal false
      Type::Union.new([Type.new(String)]).nullable?.must_equal false
      Type::Union.new([Type.new(NilClass), Type.new(String)]).nullable?.must_equal true
    end

    describe "union" do
      it "automatically wraps classes as types when creating a union type" do
        Type::Union.new([Type.new(String), Type.new(Symbol)]).must_equal Type::Union.new([String, Symbol])
      end

      it "returns a union type" do
        type = Type.new(String) | Type.new(Symbol) | Type.new(String)
        type.must_equal Type::Union.new([Type.new(String), Type.new(Symbol)])
        type = Type.new(String) | (Type.new(Symbol) | Type.new(String))
        type.must_equal Type::Union.new([Type.new(String), Type.new(Symbol)])
      end

      it "returns the prominent type, which is a single other type than null" do
        Type::Union.new([Type.new(String)]).prominent_type.must_equal Type.new(String)
        (Type.new(String) | Type.new(NilClass)).prominent_type.must_equal Type.new(String)

        Type::Union.new([Type.new(NilClass)]).prominent_type.must_equal nil
        (Type.new(String) | Type.new(Symbol)).prominent_type.must_equal nil
        (Type.new(String) | Type.new(Symbol) | Type.new(NilClass)).prominent_type.must_equal nil
      end

      it "returns whether or not it’s empty" do
        Type::Union.new.empty?.must_equal true
        Type::Union.new([Type.new(String)]).empty?.must_equal false
      end
    end

    describe "list" do
      it "wraps a hash" do
        type = Type::Hash.new
        type.type.must_equal Hash
        type.storage[:keys].must_equal Type::Union.new
        type.storage[:values].must_equal Type::Union.new
        type.empty?.must_equal true

        type = Type.of(:foo => "bar", "baz" => 42, :another => 21)
        type.type.must_equal Hash
        type.storage[:keys].must_equal Type::Union.new([Symbol, String])
        type.storage[:values].must_equal Type::Union.new([String, Fixnum])
        type.empty?.must_equal false
      end

      it "wraps an array" do
        type = Type::Array.new
        type.type.must_equal Array
        type.storage[:values].must_equal Type::Union.new
        type.empty?.must_equal true

        type = Type::Array.new(String)
        type.type.must_equal Array
        type.storage[:values].must_equal Type::Union.new([String])
        type.empty?.must_equal false

        type = Type.of([:foo, "bar", 42, :another, 21])
        type.type.must_equal Array
        type.storage[:values].must_equal Type::Union.new([String, Symbol, Fixnum])
        type.empty?.must_equal false
      end

      it "wraps a set" do
        type = Type::Set.new
        type.type.must_equal Set
        type.storage[:values].must_equal Type::Union.new
        type.empty?.must_equal true

        type = Type::Set.new(String)
        type.type.must_equal Set
        type.storage[:values].must_equal Type::Union.new([String])
        type.empty?.must_equal false

        type = Type.of(Set.new([:foo, "bar", 42, :another, 21]))
        type.type.must_equal Set
        type.storage[:values].must_equal Type::Union.new([String, Symbol, Fixnum])
        type.empty?.must_equal false
      end
    end

    describe "normalize" do
      it "returns self if it's not a union" do
        Type.new(String).normalize.must_equal(Type.new(String))
      end

      it "prefers more detailed arrays" do
        type = Type::Array.new(String) | Type::Array.new
        type.normalize.must_equal(Type::Array.new(String))
      end

      it "prefers more detailed sets" do
        type = Type::Set.new(String) | Type::Set.new
        type.normalize.must_equal(Type::Set.new(String))
      end

      it "prefers more detailed hashes" do
        type = Type::Hash.new(Symbol => Fixnum) | Type::Hash.new
        type.normalize.must_equal(Type::Hash.new(Symbol => Fixnum))
      end

      it "leaves non-collection types in tact" do
        type = Type::Array.new(String) | Type.new(Symbol)
        type.normalize.must_equal(type)
      end

      it "flattens unions" do
        type = Type::Union.new([Type.new(String) | Type.new(Boolean), Type.new(Symbol) | Type.new(Boolean)])
        type.normalize.must_equal Type.new(String) | Type.new(Symbol) | Type.new(Boolean)
      end
    end
  end
end
