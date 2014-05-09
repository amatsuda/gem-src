require 'rubygems'
require 'net/https'
require 'fileutils'

module Gem
  class Src
    DIR_PLACEHOLDER = '{dir}'

    attr_reader :installer

    def initialize(installer)
      @installer, @tested_repositories = installer, []
    end

    def clone_dir(repository)
      if gemsrc_clone_root
        clone_root = gemsrc_clone_root
        if clone_root.include?(DIR_PLACEHOLDER)
          clone_root = clone_root.gsub(DIR_PLACEHOLDER, directory_for_repository(repository))
          FileUtils.mkdir_p(File.expand_path(clone_root))
        end

        File.expand_path installer.spec.name, clone_root
      else
        gem_dir = installer.respond_to?(:gem_dir) ? installer.gem_dir : File.expand_path(File.join(installer.gem_home, 'gems', installer.spec.full_name))
        File.join gem_dir, 'src'
      end
    end

    def gemsrc_clone_root
      ENV['GEMSRC_CLONE_ROOT'] || Gem.configuration[:gemsrc_clone_root]
    end

    def directory_for_repository(repository)
      if %r{\A.+(?:@|://)(.+)/.+\z} =~ repository
        $1.gsub(":", "/")
      else
        ""
      end
    end

    def github_url(url)
      if url =~ /\Ahttps?:\/\/([^.]+)\.github.com\/(.+)/
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

    def api
      require 'open-uri'
      @api ||= open("http://rubygems.org/api/v1/gems/#{installer.spec.name}.yaml", &:read)
    rescue OpenURI::HTTPError
      ""
    end

    def source_code_uri
      api[/^source_code_uri: (.*)$/, 1]
    end

    def homepage_uri
      api[/^homepage_uri: (.*)$/, 1]
    end

    def github_organization_uri(name)
      "https://github.com/#{name}/#{name}"
    end

    def git_clone(repository)
      return if repository.nil? || repository.empty?
      return if @tested_repositories.include? repository
      @tested_repositories << repository
      return if github?(repository) && !github_page_exists?(repository)
      return unless git?(repository)

      clone_to = clone_dir(repository)
      return true if File.exist?(clone_to)
      system 'git', 'clone', repository, clone_to
    end

    def git_clone_homepage_or_source_code_uri_or_homepage_uri_or_github_organization_uri
      git_clone(installer.spec.homepage) ||
        git_clone(github_url(installer.spec.homepage)) ||
        git_clone(source_code_uri) ||
        git_clone(homepage_uri) ||
        git_clone(github_url(homepage_uri)) ||
        git_clone(github_organization_uri(installer.spec.name))
    end
  end
end


Gem.post_install do |installer|
  next true if installer.class.name == 'Bundler::Source::Path::Installer'
  Gem::Src.new(installer).git_clone_homepage_or_source_code_uri_or_homepage_uri_or_github_organization_uri
  true
end
