require "test_helper"

module Gravitype
  describe "Data introspection of Mongoid backed fields" do
    include Type::DSL

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

    # TODO: As stated in the DSL#Set? docs, mongo/mongoid does not return `null` for set fields.
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
      values.each do |value|
        TestDoc.create!(field => value)
      end
      introspection = Introspection::Data.new(TestDoc)
      # introspection.visitors = [Introspection::Data::Visitor::Mongoid.new]
      introspection.introspect[:mongoid_data][field]
    end
  end

  describe "Data introspection of json_fields" do
    include Type::DSL

    describe "concerning immediate fields" do
      before do
        TestDoc.create!
        @introspection = Introspection::Data.new(TestDoc).introspect
      end

      it "returns `json_fields :all`" do
        @introspection[:all_json_fields].map(&:name).must_equal([
          :ruby_method,
          :ruby_proc,
          :mongoid_string,
          :mongoid_array,
          :mongoid_hash,
        ])
      end

      it "returns `json_fields :public`" do
        @introspection[:public_json_fields].map(&:name).must_equal([
          :ruby_method,
          :mongoid_string,
          :mongoid_array,
        ])
      end

      it "returns `json_fields :short`" do
        @introspection[:short_json_fields].map(&:name).must_equal([
          :ruby_method,
          :mongoid_string,
        ])
      end

      it "retrieves the value of ruby method backed fields" do
        field = @introspection[:all_json_fields][:ruby_method]
        field.type.must_equal String!
      end

      it "retrieves the value of ruby proc backed fields" do
        field = @introspection[:all_json_fields][:ruby_proc]
        field.type.must_equal Symbol!
      end
    end

    describe "concerning nested models" do
      it "uses references for nested models" do
        create_art_fixtures!

        introspection = Introspection::Data.new(Artist).introspect
        introspection[:all_json_fields][:artworks].type.must_equal Array!(Reference!("Artwork.all_json_fields"))
        introspection[:public_json_fields][:artworks].type.must_equal Array!(Reference!("Artwork.short_json_fields"))
        introspection[:short_json_fields][:artworks].type.must_equal Array!(Reference!("Artwork.short_json_fields"))

        introspection = Introspection::Data.new(Artwork).introspect
        introspection[:all_json_fields][:gene].type.must_equal Reference!("Gene.public_json_fields")
        introspection[:public_json_fields][:gene].type.must_equal Reference!("Gene.public_json_fields")
        introspection[:short_json_fields][:gene].must_be_nil
      end
    end
  end
end
