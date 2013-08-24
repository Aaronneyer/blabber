require 'sinatra'
require 'data_mapper'
require 'dm-migrations'

set :bind, '0.0.0.0'
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String
  property :encrypted_password, String
  has n, :blabs
end

class Blab
  include DataMapper::Resource

  property :id, Serial
  property :body, String
  belongs_to :user
end

get '/' do
  erb :index
end

DataMapper.auto_upgrade!
