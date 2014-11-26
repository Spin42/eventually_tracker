# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'eventually_tracker/version'

Gem::Specification.new do |spec|
  spec.name          = "eventually_tracker"
  spec.version       = EventuallyTracker::VERSION
  spec.authors       = ["Lo\xC3\xAFc Vigneron"]
  spec.email         = ["loic.vigneron@gmail.com"]
  spec.summary       = "Track your application events."
  spec.description   = "Track all your controller events and model changes seamlessly and without code pollution."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "rest-client"
  spec.add_dependency "redis"
  spec.add_dependency "logging"
end
