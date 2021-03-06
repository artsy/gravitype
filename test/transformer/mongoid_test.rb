require "test_helper"

module Gravitype
  module Transformer
    describe Mongoid do
      include Type::DSL

      it "converts TrueClass to Boolean" do
        transformed = Mongoid.transform_field(Field.new(:foo, TrueClass!))
        transformed.must_equal Field.new(:foo, Boolean!)
      end

      it "converts FalseClass to Boolean" do
        transformed = Mongoid.transform_field(Field.new(:foo, FalseClass!))
        transformed.must_equal Field.new(:foo, Boolean!)
      end

      it "converts Fixnum to Integer" do
        transformed = Mongoid.transform_field(Field.new(:foo, Fixnum!))
        transformed.must_equal Field.new(:foo, Integer!)
      end

      it "converts ActiveSupport::TimeWithZone to Time" do
        transformed = Mongoid.transform_field(Field.new(:foo, Type.new(ActiveSupport::TimeWithZone)))
        transformed.must_equal Field.new(:foo, Time!)
      end

      it "converts types in a union and reduces" do
        transformed = Mongoid.transform_field(Field.new(:foo, TrueClass! | FalseClass! | Boolean!))
        transformed.must_equal Field.new(:foo, Boolean!)
      end

      it "converts types in an array and reduces" do
        transformed = Mongoid.transform_field(Field.new(:foo, Array!(TrueClass!, FalseClass!, Boolean!)))
        transformed.must_equal Field.new(:foo, Array!(Boolean!))
      end

      it "converts types in a set and reduces" do
        transformed = Mongoid.transform_field(Field.new(:foo, Set!(TrueClass!, FalseClass!, Boolean!)))
        transformed.must_equal Field.new(:foo, Set!(Boolean!))
      end

      it "converts types in a hash and reduces" do
        transformed = Mongoid.transform_field(Field.new(:foo, Hash!((TrueClass! | FalseClass! | Boolean!) => (TrueClass! | FalseClass! | Boolean!))))
        transformed.must_equal Field.new(:foo, Hash!(Boolean! => Boolean!))
      end

      it "reduces Object if there’s any other type than null" do
        transformed = Mongoid.transform_field(Field.new(:foo, Object!))
        transformed.must_equal Field.new(:foo, Object!)

        transformed = Mongoid.transform_field(Field.new(:foo, Object! | String!))
        transformed.must_equal Field.new(:foo, String!)

        transformed = Mongoid.transform_field(Field.new(:foo, Object?))
        transformed.must_equal Field.new(:foo, Object?)
      end
    end
  end
end
