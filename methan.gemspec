# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'methan/version'

Gem::Specification.new do |spec|
  spec.name          = "methan"
  spec.version       = Methan::VERSION
  spec.authors       = ["Shinichirow KAMITO"]
  spec.email         = ["shinichirow@kamito.net"]

  spec.summary       = %q{Methan is a memo organizer.}
  spec.description   = %q{Methan is a memo organizer.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19"
  spec.add_dependency "rack", "~> 1.4"
  spec.add_dependency "redcarpet", "~> 3.2"
  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
