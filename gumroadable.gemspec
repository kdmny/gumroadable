# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "gumroadable"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gumroadable"
  s.version     = Gumroadable::VERSION
  s.authors     = ["kdmny"]
  s.email       = ["kdmny30@gmail.com"]
  s.homepage    = "http://github.com/kdmny/gumroadable"
  s.summary     = "Simplifying Gumroad management for Rails apps."
  s.description = "Simplifying Gumroad management for Rails apps."

  s.files         = `git ls-files`.split($/)
  s.test_files = Dir["test/**/*"]
  s.require_paths = ["lib"]
end
