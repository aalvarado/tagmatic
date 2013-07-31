# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tagmatic'

Gem::Specification.new do |spec|
  spec.name          = "tagmatic"
  spec.version       = TagMatic::VERSION
  spec.authors       = ["Adan Alvarado"]
  spec.email         = ["adan.alvarado7@gmail.com"]
  spec.description   = %q{Automatically regenarate ctags files with Git hooks}
  spec.summary       = %q{Tagmatic will recreate the tags (ctags) file for you whenever your HEAD changes}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
