# sinatra-api-sample

json api server using sinatra

## Settings

```bash
bundle init
```

Append gem **sinatra** in Gemfile.

```ruby
# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# gem "rails"

gem 'sinatra'
```

```bash
bundle install --path vendor/bundle
```

## Hello sinatra

Touch index.rb and execute this.

```ruby
require "bundler/setup"
require 'sinatra'
require 'json'

get '/' do
  content_type :json
  response = {
    body: 'welcome to sinatra',
  }
  response.to_json
end
```

```bash
ruby index.rb
```

Access to [http://localhost:4567](http://localhost:4567)

You'll get the message JSON format from the localhost.

```json
{ "body": "welcome to sinatra" }
```

## Named parameter

Append a new get method with **Named parameter**.

```ruby
get '/books/:id' do
  content_type :json
  response ={
    body: params[:id]
  }
  response.to_json
end
```

Access to [http://localhost:4567/books/2](http://localhost:4567/books/2)

```json
{ "body": "2" }
```

## Capistrano

Append puma and capistrano gems in Gemfile.

```ruby
# puma
gem 'puma'

# for deploy
group :development do
  gem 'capistrano',         require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano3-puma',   require: false
  gem 'capistrano-rbenv',   require: false
end
```

...and install capistrano

```bash
bundle exec cap install
```

Append commands as follows in Capfile.

```ruby
require 'capistrano/setup'
require 'capistrano/deploy'
require 'capistrano/rbenv'
require 'capistrano/bundler'
require 'capistrano/puma'

install_plugin Capistrano::Puma
```

Modify `config/deploy.rb` and `config/deploy/production.rb`

deploy.rb

```ruby
# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, '<application name>'

# git
set :repo_url, 'https://<repository>.git'
set :deploy_via, :remote_cache

# rbenv
set :rbenv_type, :user
set :rbenv_ruby, '2.3.3'

# deploy
set :deploy_to, "/var/www/#{fetch(:application)}"
set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system',
  'public/uploads'
)

namespace :deploy do
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts 'WARNING: HEAD is not the same as origin/master'
        puts 'Run `git push` to sync changes.'
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      Rake::Task['puma:restart'].reenable
      invoke 'puma:restart'
    end
  end
  before :starting,  :check_revision
  after  :finishing, :cleanup
end

# puma
set :puma_threads,    [4, 16]
set :puma_workers,    0
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end
  before :start, :make_dirs
end
```

production.rb

```ruby
server '<server_name>', roles: %i[app web db]
set :user, '<user>'
set :stage, :production
set :ssh_options, forward_agent: true

```

Touch config.ru

```ruby
require './index'
run Sinatra::Application
```

## Deploy

### initial deploy 

```bash
bundle exec cap production deploy:initial
```

### server restart

```bash
bundle exec cap production deploy:restart
```

## Nginx

Touch nginx.conf

```conf
upstream <app_name> {
    server unix:/var/www/<app_name>/shared/tmp/sockets/<app_name>-puma.sock fail_timeout=0;
}

server {
    listen 80;
    server_name <server_name>; 
    root /var/www/<app_name>/current/public;

    location / {
      proxy_pass http://<app_name>;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $http_host;
    }

    access_log /var/log/nginx/<app_name>.access.log;
    error_log /var/log/nginx/<app_name>.error.log;

    error_page 500 502 503 504 /500.html;
    client_max_body_size 4G;
    keepalive_timeout 10;
}
```

Restart nginx

```bash
sudo systemctl restart nginx
```

## References

[https://tisnote.com/sinatra-web-setup-deploy/](https://tisnote.com/sinatra-web-setup-deploy/)
