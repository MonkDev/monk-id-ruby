lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'monk/id/version'

Gem::Specification.new do |spec|
  spec.name          = 'monk-id'
  spec.version       = Monk::Id::VERSION.dup
  spec.authors       = ['Monk Development, Inc.']
  spec.email         = ['support@monkdevelopment.com']
  spec.summary       = 'Integrate Monk ID authentication and single sign-on ' \
                       'for apps and websites on the server-side.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/MonkDev/monk-id-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'codecov', '~> 0.1.9'
  spec.add_development_dependency 'gem-release', '~> 0.7.4'
  spec.add_development_dependency 'rake', '~> 12.0.0'
  spec.add_development_dependency 'redcarpet', '~> 3.4.0'
  spec.add_development_dependency 'rspec', '~> 3.5.0'
  spec.add_development_dependency 'rubocop', '~> 0.46.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.9.1'
  spec.add_development_dependency 'simplecov', '~> 0.12.0'
  spec.add_development_dependency 'yard', '~> 0.9.5'
end
