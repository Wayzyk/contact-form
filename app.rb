require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'pry-byebug'
require 'recaptcha'

Recaptcha.configure do |config|
  config.site_key  = '6Le7oRETAAAAAETt105rjswZ15EuVJiF7BxPROkY'
  config.secret_key = '6Le7oRETAAAAAL5a8yOmEdmDi3b2pH7mq5iH1bYK'
end

include Recaptcha::Adapters::ControllerMethods
include Recaptcha::Adapters::ViewMethods

get '/' do
  erb :create
end

post '/' do
  @user_name = params[:user_name]
  @email = params[:email]
  @message = params[:message]

  unless params[:file] &&
         (tmpfile = params[:file][:tempfile]) &&
         (name = params[:file][:filename])
    @error = "No file selected"
    return erb :create
  end

  hh = {
    user_name: "Can't be blank",
    email: "Can't be blank",
    message: 'Too short'
  }

  @error = hh.select {|key,_| params[key] == ''}.values.join(", ")

  if @error != '' || !verify_recaptcha
    return erb :create
  else
    'Form created'
  end
end
