require 'rubygems'

Gem.post_install do |installer|
  clone_dir = if ENV['GEMSRC_CLONE_ROOT']
    File.expand_path ENV['GEMSRC_CLONE_ROOT'], installer.spec.name
  elsif Gem.configuration[:gemsrc_clone_root]
    File.expand_path Gem.configuration[:gemsrc_clone_root], installer.spec.name
  else
    gem_dir = installer.respond_to?(:gem_dir) ? installer.gem_dir : File.expand_path(installer.gem_home, 'gems', installer.spec.full_name)
    File.join gem_dir, 'src'
  end

  if (repo = installer.spec.homepage) && !repo.empty? && !File.exists?(clone_dir)
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
      `git clone #{repo} #{clone_dir}`
    end
  end
end
