require 'spec_helper'

describe Gem::Src do
  def quick_gem(name, version='2')
    require 'rubygems/specification'

    spec = Gem::Specification.new do |s|
      s.platform    = Gem::Platform::RUBY
      s.name        = name
      s.version     = version
      s.author      = 'A User'
      s.email       = 'example@example.com'
      s.homepage    = 'http://example.com'
      s.summary     = "this is a summary"
      s.description = "This is a test description"

      yield(s) if block_given?
    end

    Gem::Specification.map # HACK: force specs to (re-)load before we write

    written_path = write_file spec.spec_file do |io|
      io.write spec.to_ruby_for_cache
    end

    spec.loaded_from = spec.loaded_from = written_path

    Gem::Specification.add_spec spec.for_cache

    spec
  end

  describe '#clone_dir' do
    subject do
      gem = quick_gem 'my_awesome_gem'
      installer = Gem::Installer.new gem
      installer.stub(:gem_dir, '~/g/my_awesome_gem')
      Gem::Src.new installer
    end
    context "with ENV['GEMSRC_CLONE_ROOT']" do
      around do |example|
        e, g = ENV['GEMSRC_CLONE_ROOT'], Gem.configuration[:gemsrc_clone_root]
        ENV['GEMSRC_CLONE_ROOT'], Gem.configuration[:gemsrc_clone_root] = '~/foo', nil
        example.run
        ENV['GEMSRC_CLONE_ROOT'], Gem.configuration[:gemsrc_clone_root] = e, g
      end
      its(:clone_dir) { should == '~/foo/my_awesome_gem' }
    end

    context "with Gem.configuration[:gemsrc_clone_root]" do
      around do |example|
        e, g = ENV['GEMSRC_CLONE_ROOT'], Gem.configuration[:gemsrc_clone_root]
        ENV['GEMSRC_CLONE_ROOT'], Gem.configuration[:gemsrc_clone_root] = nil, '~/bar'
        example.run
        ENV['GEMSRC_CLONE_ROOT'], Gem.configuration[:gemsrc_clone_root] = e, g
      end
      its(:clone_dir) { should == '~/bar/my_awesome_gem' }
    end

    context "without clone_root configuration" do
      around do |example|
        e, g = ENV['GEMSRC_CLONE_ROOT'], Gem.configuration[:gemsrc_clone_root]
        ENV['GEMSRC_CLONE_ROOT'], Gem.configuration[:gemsrc_clone_root] = nil, nil
        example.run
        ENV['GEMSRC_CLONE_ROOT'], Gem.configuration[:gemsrc_clone_root] = e, g
      end
      its(:clone_dir) { should == '~/aho/my_awesome_gem/src' }
    end

  end
end
