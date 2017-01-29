$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "gravitype"

require "mongoid"
require "mongoid-cached-json"

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

  fields = Mongoid::Fields::TYPE_MAPPINGS.keys.inject({}) do |hash, name|
    hash["mongoid_#{name}".to_sym] = {}
    hash
  end
  fields[:ruby_method] = { definition: :ruby_method? }

  json_fields(fields)
end
