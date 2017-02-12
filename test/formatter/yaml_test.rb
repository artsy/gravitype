require "test_helper"
require "gravitype/formatter/yaml"

module Gravitype
  module Formatter
    describe YAML do
      include Type::DSL

      before do
        create_art_fixtures!
        @introspection = Introspection.introspect(Artist, Artwork)
        @yaml = YAML.dump(@introspection)
      end

      it "serializes an introspection" do
        @yaml.must_equal <<-EOS
Artist:
  mongoid_schema:
    _id: ObjectId!
    names: Array!
    birthdate: Date!

  mongoid_data:
    _id: ObjectId!
    names: Array!(String!)
    birthdate: Date?

  all_json_fields:
    artworks: Array!(Reference!("Artwork.all_json_fields"))
    birthdate: Date?
    names: Array!(String!)

  public_json_fields:
    artworks: Array!(Reference!("Artwork.short_json_fields"))
    birthdate: Date?
    names: Array!(String!)

  short_json_fields:
    artworks: Array!(Reference!("Artwork.short_json_fields"))
    names: Array!(String!)

  merged:
    _id: ObjectId!
    names: Array!(String!)
    birthdate: Date?
    artworks: Array!(Reference!("Artwork.all_json_fields"), Reference!("Artwork.short_json_fields"))

Artwork:
  mongoid_schema:
    _id: ObjectId!
    artist_id: Object!
    gene_id: Object!
    title: Object!

  mongoid_data:
    _id: ObjectId!
    artist_id: ObjectId!
    gene_id: ObjectId!
    title: String!

  all_json_fields:
    gene: Reference!("Gene.public_json_fields")
    title: String!

  public_json_fields:
    gene: Reference!("Gene.public_json_fields")
    title: String!

  short_json_fields:
    title: String!

  merged:
    _id: ObjectId!
    artist_id: Object! | ObjectId!
    gene_id: Object! | ObjectId!
    title: Object! | String!
    gene: Reference!("Gene.public_json_fields")

EOS
      end

      it "deserializes an introspection" do
        YAML.load(@yaml).must_equal(@introspection)
      end

      it "deserializes null values" do
        YAML.load(<<-EOS
Artist:
  mongoid_data:
    names: null
EOS
        ).must_equal({
          "Artist" => {
            mongoid_data: [
              Field.new(:names, Type.new(NilClass))
            ]
          }
        })
      end
    end
  end
end
