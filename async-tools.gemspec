# frozen_string_literal: true

require_relative "lib/async/tools/version"

Gem::Specification.new do |spec|
  spec.name          = "async-tools"
  spec.version       = Async::Tools::VERSION
  spec.authors       = ["Gleb Sinyavskiy"]
  spec.email         = ["zhulik.gleb@gmail.com"]

  spec.summary       = "A set of useful tools for async programming with Async."
  spec.description   = "A set of useful tools for async programming with Async."
  spec.homepage      = "https://github.com/zhulik/async-tools"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.2.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/zhulik/async-tools"
  # spec.metadata["changelog_uri"] = "https://github.com/zhulik/async-tools/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "async", "~> 2.3"
  spec.add_dependency "zeitwerk", "~> 2.6"
  spec.metadata["rubygems_mfa_required"] = "true"
end
