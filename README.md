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
