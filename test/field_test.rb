require "test_helper"

module Gravitype
  describe Field do
    it "initializes" do
      field = Field.new(:foo, Type.new(String))
      field.name.must_equal(:foo)
      field.type.type.must_equal(String)
    end

    it "merges" do
      field = Field.new(:foo, Type.new(NilClass))
      merged_field = field.merge(Field.new(:foo, Type.new(String)))
      merged_field.name.must_equal(:foo)
      merged_field.type.must_equal(Type::Union.new([NilClass, String]))
      field.type.must_equal(Type.new(NilClass))
    end

    it "merges in place" do
      field = Field.new(:foo, Type.new(NilClass))
      field.merge!(Field.new(:foo, Type.new(String)))
      field.name.must_equal(:foo)
      field.type.must_equal(Type::Union.new([NilClass, String]))
    end

    describe "normalize" do
      it "prefers more detailed arrays" do
        types = Type::Array.new(String) | Type::Array.new
        Field.new(:foo, types).normalize.type.must_equal(Type::Array.new(String))
      end

      it "prefers more detailed sets" do
        types = Type::Set.new(String) | Type::Set.new
        Field.new(:foo, types).normalize.type.must_equal(Type::Set.new(String))
      end

      it "prefers more detailed hashes" do
        types = Type::Hash.new(Symbol => Fixnum) | Type::Hash.new
        Field.new(:foo, types).normalize.type.must_equal Type::Hash.new(Symbol => Fixnum)
      end
    end
  end
end
