# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "gem-src"
  gem.version       = '0.6.2'
  gem.authors       = ["Akira Matsuda"]
  gem.email         = ["ronnie@dio.jp"]
  gem.description   = 'Gem.post_install { `git clone gem_source src` }'
  gem.summary       = 'Gem.post_install { `git clone gem_source src` }'
  gem.homepage      = 'https://github.com/amatsuda/gem-src'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'rspec', ['>= 0']

  gem.post_install_message = <<-END
[gem-src] If you have not yet configured "gemsrc_clone_root", we strongly recommend you to add the configuration to your .gemrc.

e.g.)
% echo "gemsrc_clone_root: ~/src" >> ~/.gemrc

See README for more details.
END
end
