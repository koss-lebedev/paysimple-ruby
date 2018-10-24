lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paysimple/version'

Gem::Specification.new do |spec|
  spec.name          = 'paysimple-ruby'
  spec.version       = Paysimple::VERSION
  spec.authors       = ['Konstantin Lebedev']
  spec.email         = ['koss.lebedev@gmail.com']

  spec.summary       = 'Ruby bindings for Paysimple API'
  spec.description   = ''
  spec.homepage      = 'http://developer.paysimple.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'

  spec.add_dependency('rest-client', '~> 2')
  spec.add_dependency('json', '~> 1.8.1')
end
