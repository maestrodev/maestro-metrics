# -*- encoding: utf-8 -*-
require File.expand_path('../lib/maestro_metrics/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Etienne Pelletier"]
  gem.email         = ["epelletier@maestrodev.com"]
  gem.description   = "A gem used to log application metrics"
  gem.summary       = "Use this gem to record application run time metrics."
  gem.homepage      = "https://github.com/kellyp/maestro-metrics"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "maestro_metrics"
  gem.require_paths = ["lib"]
  gem.version       = Maestro::Metrics::VERSION

  gem.add_dependency('mongo')
  gem.add_dependency('statsd')
  gem.add_dependency('statsd-ruby')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('mongo_mapper')
end
