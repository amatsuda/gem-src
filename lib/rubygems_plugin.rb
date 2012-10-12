require 'rubygems'

Gem.post_install do |installer|
  if installer.spec.homepage && !File.exists?("#{installer.gem_dir}/src") && !`git ls-remote #{installer.spec.homepage} 2> /dev/null`.empty?
    Dir.chdir installer.gem_dir do
      `git clone #{installer.spec.homepage} src`
    end
  end
end
