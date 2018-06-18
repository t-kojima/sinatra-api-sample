require 'bundler/setup'
require 'sinatra'
require 'json'
require './db/database'

get '/' do
  content_type :json
  response = {
    body: 'welcome to sinatra'
  }
  response.to_json
end

get '/books/:id' do
  content_type :json
  response = {
    body: Book.where(id: params[:id])
  }
  response.to_json
end
