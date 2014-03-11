# gem-src

A gem plugin that automatically `git clone`s the gem's source right after every `gem install` so you can `git log`, `git grep` and of course write your patch there!


## Installation

    $ gem install gem-src

If you want to enable this as a rbenv plugin, then run:

    $ git clone https://github.com/amatsuda/gem-src.git ~/.rbenv/plugins/gem-src

and you get gem-src enabled for all gem and bundle commands invoked through rbenv.

## Configuration

### By default

With this gem installed, every `gem install` you perform will be followed by automatic `git clone` into the installed gem's "src" directory (if the gemspec's "homepage" property points to a Git repo).

For example, when you execute

    % gem i kaminari
and if the gem is installed into `~/.gem/ruby/1.8/kaminari-0.14.1` directory, you'll see Kaminari's full Git repo at `~/.gem/ruby/1.8/kaminari-0.14.1/src` directory.

So, the whole directory structure will be like this.

    ~/.gem/ruby/1.8
    ├── gems
    │   ├── arel-3.0.2
    │   │   ├── src
    │   ├── gem-src-0.2.0
    │   │   ├── src
    │   ├── kaminari-0.14.0
    │   │   ├── src
    │   ├── kaminari-0.14.1
    │   │   ├── src
    ...
Note that if you're using RVM, each of `~/.rvm/gems/*/gems/*` will have it's Git repo inside "src" directory.

### specifying gemsrc_clone_root

Instead of cloning the repo under installed gem directory for each `gem install`, you can specify one single directory to keep all the cloned source repositories.

This way, `git clone` will no more be executed per every `gem update`.
This option would be more efficient particularly if you're frequently switching RVM gemsets, or using bundler with `--path` per each projects.
There are two ways to specify this variable:

    1) `GEMSRC_CLONE_ROOT` environment variable
    2) add `gemsrc_clone_root` configuration in your .gemrc

For example,

    % echo "gemsrc_clone_root: ~/src" >> ~/.gemrc
    % gem i active_decorator
will clone the source Git repo into `~/src/active_decorator` directory if not exists.

Now, the whole directory structure will look like this.

    ~
    ├── src
    │   ├── active_decorator
    │   ├── capybara
    │   ├── i18n_generators
    ...


## Usage

When you firstly installed this gem, you might want to type in this command right after the installation.

    % gem pristine --all
This will reinstall all the already installed gems, and so will `git clone` all the repos.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
