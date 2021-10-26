# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gravitype/version'

Gem::Specification.new do |spec|
  spec.name          = "gravitype"
  spec.version       = Gravitype::VERSION
  spec.authors       = ["Eloy Durán"]
  spec.email         = ["eloy.de.enige@gmail.com"]

  spec.summary       = "Typing support for Gravity, Artsy’s Core API."
  spec.homepage      = "https://github.com/artsy/gravitype"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mongoid"
  spec.add_runtime_dependency "mongoid-cached-json"
  spec.add_runtime_dependency "parallel"
  spec.add_runtime_dependency "ruby-progressbar"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-around", "~> 0.4"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "minitest-sprint"
  spec.add_development_dependency "minitest-focus"
  spec.add_development_dependency "database_cleaner", "~> 1.5"
end
