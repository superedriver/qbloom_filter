require_relative 'lib/qbloom_filter/version'

Gem::Specification.new do |spec|
  spec.name          = "qbloom_filter"
  spec.version       = BloomFilter::VERSION
  spec.authors       = ["qaz"]
  spec.email         = ["qaz@qaz.qaz"]

  spec.licenses    = ['MIT']
  spec.summary       = %q{Bloom Filter}
  spec.description   = %q{Bloom Filter with union and intersection}
  spec.homepage      = "https://github.com/superedriver/qbloom-filter"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/superedriver/qbloom-filter"
  spec.metadata["changelog_uri"] = "https://github.com/superedriver/qbloom-filter"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
