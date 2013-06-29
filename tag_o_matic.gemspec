# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "tag_o_matic"
  spec.version       = TagOMatic::VERSION
  spec.authors       = ["Adan Alvarado"]
  spec.email         = ["adan.alvarado7@gmail.com"]
  spec.description   = %q{Automatically regenarate tags files with Git hooks}
  spec.summary       = %q{Tag_o_matic will recreate the tags file for you whenever your HEAD changes}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
