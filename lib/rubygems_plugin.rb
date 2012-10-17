require 'rubygems'

Gem.post_install do |installer|
  repo = installer.spec.homepage
  if repo.nil? || repo.empty? || repo !~ /\Ahttps?:\/\/([^.]+)\.github.com\/(.+)/
    begin
      require 'open-uri'
      require 'json'
      repo = JSON.parse(open("http://rubygems.org/api/v1/gems/#{installer.spec.name}.json").read)['source_code_uri']
    rescue => e
      puts e.message
    end
  end

  if repo && !repo.empty?
    clone_dir = if ENV['GEMSRC_CLONE_ROOT']
      File.expand_path installer.spec.name, ENV['GEMSRC_CLONE_ROOT']
    elsif Gem.configuration[:gemsrc_clone_root]
      File.expand_path installer.spec.name, Gem.configuration[:gemsrc_clone_root]
    else
      gem_dir = installer.respond_to?(:gem_dir) ? installer.gem_dir : File.expand_path(File.join(installer.gem_home, 'gems', installer.spec.full_name))
      File.join gem_dir, 'src'
    end

    unless File.exists?(clone_dir)
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
end
