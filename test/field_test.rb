require "test_helper"

module Gravitype
  describe Field do
    it "initializes" do
      field = Field.new(:foo, [String, String])
      field.name.must_equal(:foo)
      field.classes.must_equal(Set.new([String]))
    end

    it "merges" do
      field = Field.new(:foo, [NilClass])
      merged_field = field.merge(Field.new(:foo, [String]))
      merged_field.name.must_equal(:foo)
      merged_field.classes.must_equal(Set.new([NilClass, String]))
      field.classes.must_equal(Set.new([NilClass]))
    end

    it "merges in place" do
      field = Field.new(:foo, [NilClass])
      field.merge!(Field.new(:foo, [String]))
      field.name.must_equal(:foo)
      field.classes.must_equal(Set.new([NilClass, String]))
    end

    describe "normalize" do
      it "prefers more detailed arrays" do
        Field.new(:foo, [[String], Array]).normalize.classes.must_equal(Set.new([[String]]))
      end

      it "prefers more detailed sets" do
        Field.new(:foo, [Set.new([String]), Set]).normalize.classes.must_equal(Set.new([Set.new([String])]))
      end

      # it "prefers more detailed hashes" do
      #   Field.new(:foo, [Hash, { Set.new([String]) => Set.new([String]) }]).normalize.classes.must_equal(Set.new({ Set.new([String]) => Set.new([String]) }]))
      # end
    end
  end
end
