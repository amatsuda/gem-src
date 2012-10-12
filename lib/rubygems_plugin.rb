require 'rubygems'

Gem.post_install do |installer|
  clone_root = ENV['GEMSRC_CLONE_ROOT'] || installer.gem_dir
  clone_dir = ENV['GEMSRC_CLONE_DIR'] || (clone_root == installer.gem_dir ? 'src' : installer.spec.name)
  if installer.spec.homepage && !installer.spec.homepage.empty? && !File.exists?("#{installer.gem_dir}/src") && !`git ls-remote #{installer.spec.homepage} 2> /dev/null`.empty?
    `git clone #{installer.spec.homepage} #{clone_root}/#{clone_dir}`
  end
end
