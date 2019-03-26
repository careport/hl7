lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "hl7/version"

Gem::Specification.new do |spec|
  spec.name = "hl7"
  spec.version = HL7::VERSION
  spec.author = "CarePort Health"
  spec.summary = <<-DESCRIPTION
    Tools for working with the worst data format ever.
    Right now, just a simple message parser.
  DESCRIPTION
  spec.homepage = "https://github.com/careport/hl7"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0")
  spec.test_files = spec.files.grep(%r{^spec/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 5.0"

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rspec", ">= 3.8"

  spec.required_ruby_version = ">= 2.6"
end
