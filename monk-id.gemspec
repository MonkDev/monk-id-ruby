# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monk/id/version'

Gem::Specification.new do |spec|
  spec.name          = 'monk-id'
  spec.version       = Monk::Id::VERSION.dup
  spec.authors       = ['Monk Development, Inc.']
  spec.email         = ['support@monkdevelopment.com']
  spec.description   = 'Integrate Monk ID on the server-side by accessing payloads from the client-side JavaScript.'
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/MonkDev/monk-id-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'rspec'
end
