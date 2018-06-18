require 'bundler/setup'
require 'activerecord-sqlserver-adapter'

ActiveRecord::Base.configurations = YAML.load_file('./db/database.yml')
ActiveRecord::Base.establish_connection(:development)

# class
class Book < ActiveRecord::Base
  self.table_name = '<books>'
end