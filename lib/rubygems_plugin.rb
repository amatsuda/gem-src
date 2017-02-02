# frozen-string-literal: true

require 'rubygems'
require 'net/https'

module Gem
  class Src
    IRREGULAR_REPOSITORIES = {'activesupport' => nil, 'actionview' => nil, 'actionpack' => nil, 'activemodel' => nil, 'activerecord' => nil, 'activejob' => nil, 'actionmailer' => nil, 'actioncable' => nil, 'railties' => nil, 'activeresource' => 'https://github.com/rails/activeresource.git', 'autoparse' => 'https://github.com/google/autoparse.git', 'aws-sdk-rails' => 'https://github.com/aws/aws-sdk-rails.git', 'bson' => 'https://github.com/mongodb/bson-ruby.git', 'compass-core' => 'https://github.com/Compass/compass.git', 'compass-import-once' => 'https://github.com/Compass/compass.git', 'cool.io' => 'https://github.com/tarcieri/cool.io.git', 'cucumber-core' => 'https://github.com/cucumber/cucumber-ruby-core.git', 'cucumber-wire' => 'https://github.com/cucumber/cucumber-ruby-wire.git', 'diff-lcs' => 'https://github.com/halostatue/diff-lcs.git', 'elasticsearch-api' => 'https://github.com/elastic/elasticsearch-ruby.git', 'elasticsearch-transport' => 'https://github.com/elastic/elasticsearch-ruby.git', 'erubis' => 'https://github.com/kwatch/erubis.git', 'geocoder' => 'https://github.com/alexreisner/geocoder', 'hirb' => 'https://github.com/cldwalker/hirb', 'html2haml' => 'https://github.com/haml/html2haml', 'io-console' => nil, 'kaminari-actionview' => nil, 'kaminari-activerecord' => nil, 'kaminari-core' => nil, 'meta_request' => 'https://github.com/dejan/rails_panel', 'method_source' => 'https://github.com/banister/method_source', 'origin' => 'https://github.com/mongoid/origin', 'padrino' => 'https://github.com/padrino/padrino-framework', 'padrino-admin' => nil, 'padrino-cache' => nil, 'padrino-core' => nil, 'padrino-gen' => nil, 'padrino-helpers' => nil, 'padrino-mailer' => nil, 'padrino-performance' => nil, 'padrino-support' => nil, 'paranoia' => 'https://github.com/rubysherpas/paranoia', 'pdf-core' => 'https://github.com/prawnpdf/pdf-core', 'pg' => nil, 'rack-mini-profiler' => 'https://github.com/MiniProfiler/rack-mini-profiler', 'raindrops' => 'https://github.com/tmm1/raindrops', 'redis-actionpack' => 'https://github.com/redis-store/redis-actionpack', 'redis-activesupport' => 'https://github.com/redis-store/redis-activesupport', 'redis-rack' => 'https://github.com/redis-store/redis-rack', 'redis-rails' => 'https://github.com/redis-store/redis-rails', 'rouge' => 'https://github.com/jneen/rouge', 'spreadsheet' => 'https://github.com/zdavatz/spreadsheet', 'thin' => 'https://github.com/macournoyer/thin', 'uniform_notifier' => 'https://github.com/flyerhzm/uniform_notifier'}.freeze
    SKIP_HOSTS = %w(wiki.github.com rubygems.org).freeze

    attr_reader :installer

    def initialize(installer)
      @installer, @tested_repositories = installer, []
    end

    # Guess the git repo from the gemspec and perform git clone
    def git_clone_homepage_or_source_code_uri_or_homepage_uri_or_github_organization_uri
      return false if skip_clone?
      return false if File.exist? clone_dir

      now = Time.now

      if IRREGULAR_REPOSITORIES.key? installer.spec.name
        return git_clone IRREGULAR_REPOSITORIES[installer.spec.name]
      end

      result = git_clone(installer.spec.homepage) ||
        git_clone(github_url(installer.spec.homepage)) ||
        git_clone(source_code_uri) ||
        git_clone(homepage_uri) ||
        git_clone(github_url(homepage_uri)) ||
        git_clone(github_organization_uri(installer.spec.name))

      if verbose?
        puts "gem-src: #{installer.spec.name} - !!! Failed to find a repo." if result.nil?
        puts "gem-src: #{installer.spec.name} - #{Time.now - now}s"
      end
      result
    end

    # git init the installed gem so that we can directly edit the files there
    def repositorize_installed_gem
      if File.directory? gem_dir
        puts "gem-src: #{installer.spec.name} - repositorizing..." if verbose?
        `cd #{gem_dir} && ! git rev-parse --is-inside-work-tree 2> /dev/null && git init && git checkout -qb gem-src_init && git add -A && git commit -m 'Initial commit by gem-src'`
      end
    end

    # git remote add from the installed gem to the cloned repo so that we can easily transfer patches
    def remote_add_src_and_origin
      if File.directory?(clone_dir) && File.directory?(gem_dir)
        puts "gem-src: #{installer.spec.name} - adding remotes..." if verbose?
        `cd #{gem_dir} && git remote add src #{clone_dir}`
        origin = `cd #{clone_dir} && git remote get-url origin`.chomp
        `cd #{gem_dir} && git remote set-url origin #{origin}` if origin
      end
    end

    private

    def clone_dir
      @clone_dir ||= if ENV['GEMSRC_CLONE_ROOT']
        File.expand_path installer.spec.name, ENV['GEMSRC_CLONE_ROOT']
      elsif Gem.configuration[:gemsrc_clone_root]
        File.expand_path installer.spec.name, Gem.configuration[:gemsrc_clone_root]
      else
        gem_dir = installer.respond_to?(:gem_dir) ? installer.gem_dir : File.expand_path(File.join(installer.gem_home, 'gems', installer.spec.full_name))
        File.join gem_dir, 'src'
      end
    end

    def gem_dir
      installer.respond_to?(:gem_dir) ? installer.gem_dir : File.expand_path(File.join(installer.gem_home, 'gems', installer.spec.full_name))
    end

    def github_url(url)
      if url =~ /\Ahttps?:\/\/([^.]+)\.github\.(?:com|io)\/(.+)/
        if $1 == 'www'
          "https://github.com/#{$2}"
        elsif $1 == 'wiki'
          # https://wiki.github.com/foo/bar => https://github.com/foo/bar
          "https://github.com/#{$2}"
        else
          # https://foo.github.com/bar => https://github.com/foo/bar
          "https://github.com/#{$1}/#{$2}"
        end
      end
    end

    def git?(url)
      !`git ls-remote #{url} 2> /dev/null`.empty?
    end

    def github?(url)
      URI.parse(url).host == 'github.com'
    end

    def github_page_exists?(url)
      Net::HTTP.new('github.com', 443).tap {|h| h.use_ssl = true }.request_head(url).code != '404'
    end

    def skip_host?(url)
      SKIP_HOSTS.include? URI.parse(url).host
    end

    def api
      require 'open-uri'
      @api ||= open("https://rubygems.org/api/v1/gems/#{installer.spec.name}.yaml", &:read)
    rescue OpenURI::HTTPError
      ""
    end

    def source_code_uri
      api_uri_for('source_code')
    end

    def homepage_uri
      api_uri_for('homepage')
    end

    def github_organization_uri(name)
      "https://github.com/#{name}/#{name}"
    end

    def git_clone(repository)
      return if repository.nil? || repository.empty?
      return if @tested_repositories.include? repository
      @tested_repositories << repository
      return if github?(repository) && !github_page_exists?(repository)
      return if skip_host?(repository)

      puts "gem-src: #{installer.spec.name} - Cloning from #{repository}..." if verbose?

      if use_ghq?
        system 'ghq', 'get', repository
      else
        system 'git', 'clone', repository, clone_dir if git?(repository)
      end
    end

    def use_ghq?
      ENV['GEMSRC_USE_GHQ'] || Gem.configuration[:gemsrc_use_ghq]
    end

    def api_uri_for(key)
      uri = api[Regexp.new("^#{key}_uri: (.*)$"), 1]
      uri =~ /\A(?:https?|git):\/\// ? uri : nil
    end

    def skip_clone?
      !!ENV['GEMSRC_SKIP']
    end

    def verbose?
      !!ENV['GEMSRC_VERBOSE'] || Gem.configuration[:gemsrc_verbose]
    end
  end
end


Gem.post_install do |installer|
  next true if installer.class.name == 'Bundler::Source::Path::Installer'

  gem_src = Gem::Src.new installer
  gem_src.git_clone_homepage_or_source_code_uri_or_homepage_uri_or_github_organization_uri

  gem_src.repositorize_installed_gem

  gem_src.remote_add_src_and_origin
  true
end
