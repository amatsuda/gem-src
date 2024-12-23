module Gem
  class Src
    IRREGULAR_REPOSITORIES = {
      'activesupport' => nil,
      'actionview' => nil,
      'actionpack' => nil,
      'activemodel' => nil,
      'activerecord' => nil,
      'activerecord-jdbcmysql-adapter' => 'https://github.com/jruby/activerecord-jdbc-adapter',
      'activerecord-jdbcpostgresql-adapter' => 'https://github.com/jruby/activerecord-jdbc-adapter',
      'activerecord-jdbcsqlite3-adapter' => 'https://github.com/jruby/activerecord-jdbc-adapter',
      'activejob' => nil,
      'actionmailbox' => nil,
      'actionmailer' => nil,
      'actioncable' => nil,
      'actiontext' => nil,
      'activestorage' => nil,
      'railties' => nil,
      'activeresource' => 'https://github.com/rails/activeresource.git',
      'autoparse' => 'https://github.com/google/autoparse.git',
      'aws-sdk-rails' => 'https://github.com/aws/aws-sdk-rails.git',
      'breadcrumbs_on_rails' => 'https://github.com/weppos/breadcrumbs_on_rails',
      'bson' => 'https://github.com/mongodb/bson-ruby.git',
      'coffee-script-source' => 'https://github.com/rails/ruby-coffee-script',
      'compass-core' => 'https://github.com/Compass/compass.git',
      'compass-import-once' => 'https://github.com/Compass/compass.git',
      'concurrent-ruby' => 'https://github.com/ruby-concurrency/concurrent-ruby/',
      'concurrent-ruby-edge' => 'https://github.com/ruby-concurrency/concurrent-ruby/',
      'concurrent-ruby-ext' => 'https://github.com/ruby-concurrency/concurrent-ruby/',
      'cool.io' => 'https://github.com/tarcieri/cool.io.git',
      'cucumber-core' => 'https://github.com/cucumber/cucumber-ruby-core.git',
      'cucumber-wire' => 'https://github.com/cucumber/cucumber-ruby-wire.git',
      'diff-lcs' => 'https://github.com/halostatue/diff-lcs.git',
      'elasticsearch' => 'https://github.com/elastic/elasticsearch-ruby.git',
      'elasticsearch-api' => 'https://github.com/elastic/elasticsearch-ruby.git',
      'elasticsearch-extensions' => 'https://github.com/elastic/elasticsearch-ruby.git',
      'elasticsearch-transport' => 'https://github.com/elastic/elasticsearch-ruby.git',
      'erubis' => 'https://github.com/kwatch/erubis.git',
      'flay' => 'https://github.com/seattlerb/flay',
      'geocoder' => 'https://github.com/alexreisner/geocoder',
      'hirb' => 'https://github.com/cldwalker/hirb',
      'houston' => 'https://github.com/nomad/houston',
      'haml-contrib' => 'https://github.com/haml/haml-contrib',
      'html2haml' => 'https://github.com/haml/html2haml',
      'io-console' => 'https://github.com/ruby/io-console',
      'kaminari-actionview' => nil,
      'kaminari-activerecord' => nil,
      'kaminari-core' => nil,
      'kwalify' => nil,
      'log4r' => 'https://github.com/colbygk/log4r',
      'meta_request' => 'https://github.com/dejan/rails_panel',
      'method_source' => 'https://github.com/banister/method_source',
      'middleman' => 'https://github.com/middleman/middleman',
      'middleman-core' => nil,
      'middleman-cli' => nil,
      'origin' => 'https://github.com/mongoid/origin',
      'padrino' => 'https://github.com/padrino/padrino-framework',
      'padrino-admin' => nil,
      'padrino-cache' => nil,
      'padrino-core' => nil,
      'padrino-gen' => nil,
      'padrino-helpers' => nil,
      'padrino-mailer' => nil,
      'padrino-performance' => nil,
      'padrino-support' => nil,
      'paranoia' => 'https://github.com/rubysherpas/paranoia',
      'pdf-core' => 'https://github.com/prawnpdf/pdf-core',
      'pg' => nil,
      'rack-mini-profiler' => 'https://github.com/MiniProfiler/rack-mini-profiler',
      'raindrops' => 'https://github.com/tmm1/raindrops',
      'redis-actionpack' => 'https://github.com/redis-store/redis-actionpack',
      'redis-activesupport' => 'https://github.com/redis-store/redis-activesupport',
      'redis-rack' => 'https://github.com/redis-store/redis-rack',
      'redis-rails' => 'https://github.com/redis-store/redis-rails',
      'rom-mapper' => 'https://github.com/rom-rb/rom-mapper',
      'rom-repository' => 'https://github.com/rom-rb/rom-repository',
      'rom-sql' => 'https://github.com/rom-rb/rom-sql',
      'rouge' => 'https://github.com/jneen/rouge',
      'rubygems-update' => nil,
      'spreadsheet' => 'https://github.com/zdavatz/spreadsheet',
      'thin' => 'https://github.com/macournoyer/thin',
      'uniform_notifier' => 'https://github.com/flyerhzm/uniform_notifier',
      'vcr' => 'https://github.com/vcr/vcr'
    }.freeze unless defined? IRREGULAR_REPOSITORIES
  end
end
