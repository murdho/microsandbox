# frozen_string_literal: true

require_relative "lib/microsandbox/version"

Gem::Specification.new do |spec|
  spec.name = "microsandbox"
  spec.version = Microsandbox::VERSION
  spec.authors = ["Microsandbox Team"]
  spec.email = ["team@microsandbox.dev"]

  spec.summary = "Microsandbox Ruby SDK"
  spec.description = "A Ruby SDK for the Microsandbox project - secure MicroVM provisioning for running untrusted code"
  spec.homepage = "https://github.com/microsandbox/microsandbox"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem
  spec.files = Dir.glob(%w[lib/**/*.rb LICENSE README.md])
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "net-http", "~> 0.4"
  spec.add_dependency "uri", "~> 0.13"
  spec.add_dependency "json", "~> 2.6"
  spec.add_dependency "async", "~> 2.6"
  spec.add_dependency "dotenv", "~> 2.8"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-reporters", "~> 1.6"
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "rubocop", "~> 1.50"
end
