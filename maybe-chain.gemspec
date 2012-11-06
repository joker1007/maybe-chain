# -*- encoding: utf-8 -*-
require File.expand_path('../lib/maybe-chain/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["joker1007"]
  gem.email         = ["kakyoin.hierophant@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "maybe-chain"
  gem.require_paths = ["lib"]
  gem.version       = MaybeChain::VERSION

  gem.add_development_dependency('rspec', '~>2.11.0')
  gem.add_development_dependency('rake')
end
