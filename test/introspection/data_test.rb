require "test_helper"

module Gravitype
  Type::Sugar.define_scalar_type("TrueClass", TrueClass)
  Type::Sugar.define_scalar_type("FalseClass", FalseClass)
  Type::Sugar.define_scalar_type("Fixnum", Fixnum)

  describe "Data introspection of Mongoid backed fields" do
    include Type::Sugar

    it "returns all types that exist for a `string` field" do
      result = introspect_field(:mongoid_string, [nil, "foo", "bar"])
      result.type.must_equal String?
    end

    it "returns all types that exist for a `symbol` field" do
      result = introspect_field(:mongoid_symbol, [nil, :foo, :bar])
      result.type.must_equal Symbol?
    end

    it "returns all types that exist for a `boolean` field" do
      result = introspect_field(:mongoid_boolean, [nil, true, true, false])
      result.type.must_equal TrueClass! | FalseClass! | null
    end

    it "returns all types that exist for a `integer` field" do
      result = introspect_field(:mongoid_integer, [nil, 21, 42])
      result.type.must_equal Fixnum?
    end

    it "returns all types that exist for a `float` field" do
      result = introspect_field(:mongoid_float, [nil, 21.0, 42.0])
      result.type.must_equal Float?
    end

    it "returns all types that exist for a `big_decimal` field" do
      result = introspect_field(:mongoid_float, [nil, BigDecimal.new("42"), BigDecimal.new("42424242424242424242424.42")])
      result.type.must_equal Float?
    end

    it "returns all types that exist for a `time` field" do
      result = introspect_field(:mongoid_time, [nil, Time.now, Time.now, "foo"])
      result.type.must_equal Time?
    end

    it "returns all types that exist for a `date` field" do
      result = introspect_field(:mongoid_date, [nil, Date.today, Date.today])
      result.type.must_equal Date?
    end

    it "returns all types that exist for a `datetime` field" do
      result = introspect_field(:mongoid_date_time, [nil, DateTime.now, DateTime.now])
      result.type.must_equal DateTime?
    end

    it "returns all types that exist for a `object_id` field" do
      result = introspect_field(:mongoid_object_id, [nil, BSON::ObjectId.new.to_s, BSON::ObjectId.new])
      result.type.must_equal ObjectId?
    end

    it "returns all types that exist for a `binary` field" do
      result = introspect_field(:mongoid_binary, [nil, "baz", BSON::Binary.new("foo"), BSON::Binary.new("bar")])
      result.type.must_equal Binary! | String! | null
    end

    it "returns all types that exist for a `range` field" do
      result = introspect_field(:mongoid_range, [nil, 21..42, 21...42])
      result.type.must_equal Range?
    end

    it "returns all types that exist for a `regexp` field" do
      result = introspect_field(:mongoid_regexp, ["foo", /foo/, /bar/])
      result.type.must_equal Regexp!
    end

    it "returns all types that exist for an `array` field" do
      result = introspect_field(:mongoid_array, [nil, [], ["foo", :bar], [42]])
      result.type.must_equal Array?(String!, Symbol!, Fixnum!)
    end

    # TODO: As stated in the Sugar#Set? docs, mongo/mongoid does not return `null` for set fields.
    it "returns all types that exist for a `set` field" do
      result = introspect_field(:mongoid_set, [nil, Set.new, Set.new(["foo", :bar]), Set.new([42])])
      result.type.must_equal Set!(String!, Symbol!, Fixnum!)
    end

    it "returns all types that exist for a `hash` field" do
      result = introspect_field(:mongoid_hash, [nil, {}, { 21 => "bar", "foo" => 42 }])
      result.type.must_equal Hash?(String! => String! | Fixnum!).normalize
    end

    private

    def introspect_field(field, values)
      values.each { |value| TestDoc.create!(field => value) }
      Gravitype::Introspection::Data.new(TestDoc).introspect(field => field).first
    end
  end

  describe "Data introspection of Ruby backed fields" do
    include Type::Sugar

    it "uses the provided method alias to get the value from the document" do
      TestDoc.create!
      result = Gravitype::Introspection::Data.new(TestDoc).introspect(:ruby_method => :ruby_method?)
      result.first.type.must_equal String!
    end
  end
end
