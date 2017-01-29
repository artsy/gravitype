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
      type = Type.new(String) | (Type.new(Symbol) | Type.new(String))
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

    describe "sugar" do
      include Type::Sugar

      it "returns a NilClass type" do
        null.must_equal Type.new(NilClass)
      end

      it "makes scalar types available" do
        Type::Sugar::SCALAR_TYPES.each do |name, klass|
          send("#{name}!").must_equal Type.new(klass)
          send("#{name}?").must_equal Type.new(klass) | null
        end
      end

      it "makes hash types available" do
        expected = Type::Hash.new(Type.new(String) => Type::Array.new(Type.new(String), Type.new(Integer)) | null).normalize
        Hash!(String! => Array?(String!, Integer!)).normalize.must_equal expected
        Hash?(String! => Array?(String!, Integer!)).normalize.must_equal expected | null
      end

      it "makes array types available" do
        expected = Type::Array.new(Type.new(String), Type.new(Mongoid::Boolean), Type.new(NilClass)).normalize
        Array!(String?, Boolean?).normalize.must_equal expected
        Array?(String?, Boolean?).normalize.must_equal expected | null
      end

      it "makes set types available" do
        expected = Type::Set.new(Type.new(String), Type.new(Mongoid::Boolean), Type.new(NilClass)).normalize
        Set!(String?, Boolean?).normalize.must_equal expected
        Set?(String?, Boolean?).normalize.must_equal expected | null
      end
    end
  end
end
