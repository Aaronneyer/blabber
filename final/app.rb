require 'sinatra'
require 'data_mapper'
require 'dm-migrations'
require 'bcrypt'

enable :sessions

set :bind, '0.0.0.0'
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")

class User
  include DataMapper::Resource

  property :id, Serial
  property :login, String
  property :password_hash, String, length: 255
  has n, :blabs
end

class Blab
  include DataMapper::Resource
  property :id, Serial
  property :body, String, length: 255
  belongs_to :user
end

helpers do
  def current_user
    @current_user ||= User.get(session['user_id'])
  end
end

get '/' do
  erb :index
end

get '/signup' do
  erb :signup
end

post '/signup' do
  if User.first(login: params['login'])
    redirect '/signup'
  end
  user = User.create(login: params['login'],
                     password_hash: BCrypt::Password.create(params['password']))
  session['user_id'] = user.id
  redirect '/'
end

get '/login' do
  erb :login
end

post '/login' do
  user = User.first(login: params['login'])
  if user && (BCrypt::Password.new(user.password_hash) == params['password'])
    session['user_id'] = user.id
    redirect '/'
  else
    redirect '/login'
  end
end

get '/logout' do
  session.delete('user_id')
  redirect '/'
end

get '/blabs' do
  @blabs = Blab.all
  erb :'blabs/index'
end

get '/blabs/new' do
  erb :'blabs/new'
end

post '/blabs' do
  Blab.create(body: params['body'], user_id: current_user.id)
  redirect '/blabs'
end

get '/users' do
  @users = User.all
  erb :'users/index'
end

get '/users/:id' do |id|
  @user = User.get(id)
  @blabs = Blab.all(user_id: id)
  erb :'users/show'
end

DataMapper.auto_upgrade!