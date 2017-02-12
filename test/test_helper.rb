$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "gravitype"

require "mongoid"
require "mongoid-cached-json"

ENV["TESTING"] = "1"

Mongoid.configure do |config|
  config.connect_to("localhost")
  config.logger.level = Logger::INFO
end
Mongo::Logger.logger = Mongoid.logger

require "minitest/around"
require "minitest/autorun"
require "minitest/focus"
require "minitest/reporters"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require "database_cleaner"
DatabaseCleaner[:mongoid].strategy = :truncation
class Minitest::Spec
  around do |tests|
    DatabaseCleaner.cleaning(&tests)
  end
end

class TestDoc
  include Mongoid::Document
  include Mongoid::CachedJson

  Mongoid::Fields::TYPE_MAPPINGS.each do |name, type|
    field "mongoid_#{name}", type: type
  end

  def ruby_method?
    "string"
  end

  json_fields({
    ruby_method:    { properties: :short, definition: :ruby_method? },
    ruby_proc:      { properties: :all,   definition: lambda { |instance| :ok } },
    mongoid_string: { properties: :short },
    mongoid_array:  { properties: :public },
    mongoid_hash:   { properties: :all },
  })
end

class Artist
  include Mongoid::Document
  include Mongoid::CachedJson

  has_many :artworks
  field :names, type: Array
  field :birthdate, type: Date

  json_fields({
    birthdate: { properties: :public },
    names:     { properties: :short },
    artworks:  { properties: :short, type: :reference },
  })
end

class Artwork
  include Mongoid::Document
  include Mongoid::CachedJson

  belongs_to :artist
  belongs_to :gene
  field :title

  json_fields({
    title: {}, # default { properties: :short }
    gene:  { properties: :public, type: :reference, reference_properties: :public },
  })
end

class Gene
  include Mongoid::Document
  include Mongoid::CachedJson

  has_many :artworks
  field :name
  field :desc

  json_fields({
    name: { properties: :short },
    desc: { properties: :public },
  })
end

def create_art_fixtures!
  gene = Gene.create!(name: "Painting", desc: "Made with paint.")
  artist = Artist.create!(names: %w(Andy Warhol), birthdate: Date.new(1928, 1, 1))
  Artwork.create!(artist: artist, title: "Flowers", gene: gene)
  artist = Artist.create!(names: %w(Banksy))
  Artwork.create!(artist: artist, title: "CHAMPAGNE FORMICA FLAG", gene: gene)
end

Gravitype::Type::DSL.define_scalar_type("TrueClass", TrueClass)
Gravitype::Type::DSL.define_scalar_type("FalseClass", FalseClass)
Gravitype::Type::DSL.define_scalar_type("Fixnum", Fixnum)
