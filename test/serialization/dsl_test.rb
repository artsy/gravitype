require "test_helper"
require "gravitype/serialization/dsl"

module Gravitype
  describe "to_dsl" do
    include Type::DSL

    it "formats a scalar" do
      (String!).to_dsl.must_equal "String!"
    end

    it "formats a union" do
      (String! | Symbol! | null).to_dsl.must_equal "String! | Symbol! | null"
    end

    it "formats an array" do
      (Array!).to_dsl.must_equal "Array!"
      (Array!(Integer!, Float!)).to_dsl.must_equal "Array!(Integer!, Float!)"
    end

    it "formats a set" do
      (Set!).to_dsl.must_equal "Set!"
      (Set!(Integer!, Float!)).to_dsl.must_equal "Set!(Integer!, Float!)"
    end

    it "formats a hash" do
      (Hash!).to_dsl.must_equal "Hash!"
      (Hash!(String! => Symbol! | Integer!)).to_dsl.must_equal "Hash!(String! => Symbol! | Integer!)"
    end

    it "does not include full constant path for special types" do
      (Boolean!).to_dsl.must_equal "Boolean!"
      (ObjectId!).to_dsl.must_equal "ObjectId!"
      (Binary!).to_dsl.must_equal "Binary!"
      (Regexp!).to_dsl.must_equal "Regexp!"
    end

    it "formats a reference" do
      (Reference!("A reference")).to_dsl.must_equal 'Reference!("A reference")'
    end

    describe "nullability" do
      it "formats a nullable scalar" do
        (String?).to_dsl.must_equal "String?"
      end

      it "formats a union" do
        (String! | null).to_dsl.must_equal "String?"
      end

      it "formats an array" do
        (Array?(Integer?)).to_dsl.must_equal "Array?(Integer?)"
      end

      it "formats a set" do
        (Set?(Integer?)).to_dsl.must_equal "Set?(Integer?)"
      end

      it "formats a hash" do
        (Hash?(String? => Symbol?)).to_dsl.must_equal "Hash?(String? => Symbol?)"
      end

      it "formats a reference" do
        (Reference?("A reference")).to_dsl.must_equal 'Reference?("A reference")'
      end
    end
  end
end
