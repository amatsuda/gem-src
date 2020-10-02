# frozen-string-literal: true

Bundler::Plugin::API.hook Bundler::Plugin::Events::GEM_AFTER_INSTALL do |spec_install|
  require_relative 'lib/rubygems_plugin'

  Gem::Src.post_install_hook spec_install
end
