# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cint/version'

Gem::Specification.new do |spec|
  spec.name          = "cint"
  spec.version       = Cint::VERSION
  spec.authors       = ["Alex Antonyuk"]
  spec.email         = ["alex@antonyuk.me"]

  spec.summary       = %q{Simplifies all routines with adding Frameworks built with Carthage into a project and creating Shell Script Build Phase}
  spec.homepage      = "https://github.com/dev4dev/cint"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w( bin/cint README.md LICENSE.txt )
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'xcodeproj'
  spec.add_dependency 'colored'
  spec.add_dependency 'commander'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
