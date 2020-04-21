require 'sinatra'
require 'sinatra/reloader'
require 'pry-byebug'

get '/' do
  erb :create
end

post '/' do
  @user_name = params[:user_name]
  @email = params[:email]
  @message = params[:message]

  hh = {
    user_name: "Can't be blank",
    email: "Can't be blank",
    message: 'Too short'
  }

  @error = hh.select {|key,_| params[key] == ''}.values.join(", ")

  if @error != ''
    return erb :create
  end
end
