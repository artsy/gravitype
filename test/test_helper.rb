$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'gravitype'

require 'mongoid'

Mongoid.configure do |config|
  config.connect_to("localhost")
  config.logger.level = Logger::INFO
end
Mongo::Logger.logger = Mongoid.logger

require 'minitest/around'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'database_cleaner'
DatabaseCleaner[:mongoid].strategy = :truncation
class Minitest::Spec
  around do |tests|
    DatabaseCleaner.cleaning(&tests)
  end
end
