# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "plate_id"
  spec.version       = "0.1.4"
  spec.authors       = ["Kobus Post", "David Kortleven", "Elena Freudenberg"]
  spec.email         = ["kobus@getplate.com"]
  spec.homepage      = "https://www.getplate.com"

  spec.summary       = "Refer to any Plate object or class by using the URI syntax: plateid://Group/Class/id"
  spec.description   = "Identify any Plate record or class with URIs. Somewhat based on Rails's GlobalID gem."
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
