# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'locoyo/version'

Gem::Specification.new do |spec|
  spec.name          = "locoyo"
  spec.version       = Locoyo::VERSION
  spec.authors       = ["Chris Teague"]
  spec.email         = ["chris@cteague.com.au"]
  spec.summary       = %q{Locoyo client app}
  spec.description   = %q{Locoyo client app}
  spec.homepage      = "https://github.com/chris-teague/locoyo"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'eventmachine', '~> 1.0', '>= 1.0.7'
  spec.add_runtime_dependency 'em-http-request', '~> 1.1', '>= 1.1.2'

  spec.add_development_dependency "pry", "~> 0.10.0"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
