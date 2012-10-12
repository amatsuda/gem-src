require 'rubygems'

Gem.post_install do |installer|
  if installer.spec.homepage && !installer.spec.homepage.empty? && !File.exists?("#{installer.gem_dir}/src")
    repo = installer.spec.homepage
    if repo =~ /\Ahttps?:\/\/([^.]+)\.github.com\/(.+)/
      repo = if $1 == 'www'
        "https://github.com/#{$2}"
      elsif $1 == 'wiki'
        # https://wiki.github.com/foo/bar => https://github.com/foo/bar
        "https://github.com/#{$2}"
      else
        # https://foo.github.com/bar => https://github.com/foo/bar
        "https://github.com/#{$1}/#{$2}"
      end
    end

    if !`git ls-remote #{repo} 2> /dev/null`.empty?
      Dir.chdir installer.gem_dir do
        `git clone #{repo} src`
      end
    end
  end
end
