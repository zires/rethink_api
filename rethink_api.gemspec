# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'rethink_api/version'

Gem::Specification.new do |s|
  s.name          = "rethink_api"
  s.version       = RethinkAPI::VERSION
  s.authors       = ["zires"]
  s.email         = ["zshuaibin@gmail.com"]
  s.homepage      = "https://github.com/zires/rethink_api"
  s.summary       = "Cache your api data by RethinkDB."
  s.description   = "Cache your api data by RethinkDB."

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.rubyforge_project = '[none]'

  s.add_dependency "rethinkdb"
  s.add_dependency "activesupport"

  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "turn"

end
