# -*- encoding: utf-8 -*-
require File.expand_path('../lib/monk-id-client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rohan Deshpande"]
  gem.email         = ["rohan.deshpande@gmail.com"]
  gem.description   = %q{Ruby client to interface with Monk ID}
  gem.summary       = %q{Ruby client to interface with Monk ID}
  gem.homepage      = "https://github.com/MonkDev/monk-id-client/"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "monk-id-client"
  gem.require_paths = ["lib"]
  gem.version       = Monk::Id::Client::VERSION

  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'typhoeus', '~> 0.6.0'
end
