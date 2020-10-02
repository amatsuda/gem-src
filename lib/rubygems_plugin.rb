# frozen-string-literal: true

require 'rubygems'
require 'net/https'

module Gem
  class Src
    class << self
      def post_install_hook(installer)
        return true if installer.class.name == 'Bundler::Source::Path::Installer'
        return true if !!ENV['GEMSRC_SKIP']

        gem_src = Gem::Src.new installer
        gem_src.git_clone_homepage_or_source_code_uri_or_homepage_uri_or_github_organization_uri

        gem_src.repositorize_installed_gem

        gem_src.remote_add_src_and_origin
        true
      end
    end

    def initialize(installer)
      @installer, @spec, @tested_repositories = installer, installer.spec, []
    end

    # Guess the git repo from the gemspec and perform git clone
    def git_clone_homepage_or_source_code_uri_or_homepage_uri_or_github_organization_uri
      return false if File.exist? clone_dir

      now = Time.now

      if IRREGULAR_REPOSITORIES.key? @spec.name
        return git_clone IRREGULAR_REPOSITORIES[@spec.name]
      end

      result = git_clone(source_code_uri_from_metadata) ||
        git_clone(@spec.homepage) ||
        git_clone(github_url(@spec.homepage)) ||
        git_clone(source_code_uri) ||
        git_clone(homepage_uri) ||
        git_clone(github_url(homepage_uri)) ||
        git_clone(github_organization_uri(@spec.name))

      if verbose?
        puts "gem-src: #{@spec.name} - !!! Failed to find a repo." if result.nil?
        puts "gem-src: #{@spec.name} - #{Time.now - now}s"
      end
      result
    end

    # git init the installed gem so that we can directly edit the files there
    def repositorize_installed_gem
      if File.directory? gem_dir
        puts "gem-src: #{@spec.name} - repositorizing..." if verbose?
        `cd #{gem_dir} && ! git rev-parse --is-inside-work-tree 2> /dev/null && git init && git checkout -qb gem-src_init && git add -A && git commit -m 'Initial commit by gem-src'`
      end
    end

    # git remote add from the installed gem to the cloned repo so that we can easily transfer patches
    def remote_add_src_and_origin
      if File.directory?(clone_dir) && File.directory?(gem_dir)
        puts "gem-src: #{@spec.name} - adding remotes..." if verbose?
        `cd #{gem_dir} && git remote add src #{clone_dir}`
        origin = `cd #{clone_dir} && git remote get-url origin`.chomp
        `cd #{gem_dir} && git config remote.origin.url #{origin}` if origin
      end
    end

    private

    def clone_dir
      @clone_dir ||= if ENV['GEMSRC_CLONE_ROOT']
        File.expand_path @spec.name, ENV['GEMSRC_CLONE_ROOT']
      elsif Gem.configuration[:gemsrc_clone_root]
        File.expand_path @spec.name, Gem.configuration[:gemsrc_clone_root]
      else
        File.join gem_dir, 'src'
      end
    end

    def gem_dir
      if @installer.respond_to?(:gem_dir)
        @installer.gem_dir
      elsif @installer.respond_to?(:gem_home)  # old rubygems
        File.expand_path(File.join(@installer.gem_home, 'gems', @spec.full_name))
      else  # bundler
        File.expand_path(File.join(Gem.dir, 'gems', @spec.full_name))
      end
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

    def source_code_uri_from_metadata
      @spec.metadata['source_code_uri']
    end

    def api
      require 'open-uri'
      @api ||= OpenURI.open_uri("https://rubygems.org/api/v1/gems/#{@spec.name}.yaml", &:read)
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
      return if repository.include? 'rubyforge.org'
      return if @tested_repositories.include? repository
      @tested_repositories << repository
      return if github?(repository) && !github_page_exists?(repository)

      puts "gem-src: #{@spec.name} - Cloning from #{repository}..." if verbose?

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

    def verbose?
      !!ENV['GEMSRC_VERBOSE'] || Gem.configuration[:gemsrc_verbose]
    end
  end unless defined?(Src) # for rubygems test suite.
end

require 'gem/src/irregular_repositories'


Gem.post_install do |installer|
  Gem::Src.post_install_hook installer
end
