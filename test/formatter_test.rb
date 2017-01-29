require "test_helper"

module Gravitype
  describe Formatter do
    include Type::Sugar

    it "formats a scalar" do
      Formatter.format(String!).must_equal "String!"
    end

    it "formats a union" do
      Formatter.format(String! | Symbol! | null).must_equal "String! | Symbol! | null"
    end

    it "formats an array" do
      Formatter.format(Array!(Integer!, Float!)).must_equal "Array!(Integer!, Float!)"
    end

    it "formats a set" do
      Formatter.format(Set!(Integer!, Float!)).must_equal "Set!(Integer!, Float!)"
    end

    it "formats a hash" do
      Formatter.format(Hash!(String! => Symbol! | Integer!)).must_equal "Hash!(String! => Symbol! | Integer!)"
    end

    it "does not include full constant path for special types" do
      Formatter.format(Boolean!).must_equal "Boolean!"
      Formatter.format(ObjectId!).must_equal "ObjectId!"
      Formatter.format(Binary!).must_equal "Binary!"
      Formatter.format(Regexp!).must_equal "Regexp!"
    end

    describe "nullability" do
      it "formats a nullable scalar" do
        Formatter.format(String?).must_equal "String?"
      end

      it "formats a union" do
        Formatter.format(String! | null).must_equal "String?"
      end

      it "formats an array" do
        Formatter.format(Array?(Integer?)).must_equal "Array?(Integer?)"
      end

      it "formats a set" do
        Formatter.format(Set?(Integer?)).must_equal "Set?(Integer?)"
      end

      it "formats a hash" do
        Formatter.format(Hash?(String? => Symbol?)).must_equal "Hash?(String? => Symbol?)"
      end
    end
  end
end
