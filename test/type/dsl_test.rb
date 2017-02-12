require "test_helper"

module Gravitype
  describe Type::DSL do
    include Type::DSL

    it "returns a NilClass type" do
      null.must_equal Type.new(NilClass)
    end

    it "makes scalar types available" do
      Type::SCALAR_TYPES.each do |name, klass|
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

    it "makes reference types available" do
      expected = Type::Reference.new("A reference")
      Reference!("A reference").normalize.must_equal expected
      Reference?("A reference").normalize.must_equal expected | null
    end
  end
end
