require 'rubygems'

module Gem
  class Src
    attr_reader :installer

    def initialize(installer)
      @installer = installer
    end

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

    def git_clone(repository, directory)
      `git clone #{repository} #{directory}` if repository && !repository.empty? && git?(repository)
    end

    def git_clone_homepage
      unless File.exists? clone_dir
        git_clone(installer.spec.homepage, clone_dir) || git_clone(github_url(installer.spec.homepage, clone_dir))
      end
    end
  end
end


Gem.post_install do |installer|
  Gem::Src.new(installer).git_clone_homepage
end
