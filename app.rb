# frozen_string_literal: true

require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/param'
require 'dotenv/load'
require 'pony'
require 'recaptcha'
require 'pry-byebug'
require 'rubocop'

include Recaptcha::Adapters::ControllerMethods
include Recaptcha::Adapters::ViewMethods

Recaptcha.configure do |config|
  config.site_key = ENV['SITE_KEY']
  config.secret_key = ENV['SECRET_KEY']
end

helpers Sinatra::Param

get '/' do
  erb :create, layout: :layout
end

post '/' do
  begin
    if ENV['RACK_ENV'] == 'production' && !verify_recaptcha(action: 'email')
      raise 'Captcha is not verified'
    end

    validate_email_params
    unless params[:file].nil?
      @attachment = { params[:file][:filename] =>
      params[:file][:tempfile].read }
    end
    send_email(params[:email], params[:message], @attachment)

    { status: 200 }.to_json
  rescue StandardError
    {
      status: 500,
      message: 'Something went wrong'
    }.to_json
  end
end

private

def send_email(from, body, attachment = nil)
  attachment = {} if attachment.nil?
  Pony.mail(
    to: params[:email],
    from: from,
    subject: "Feedback from #{params[:name]}",
    body: body,
    attachments: attachment,
    via: :smtp,
    via_options: pony_options
  )
end

def pony_options
  {
    address: 'smtp.sendgrid.net',
    port: ENV[PORT],
    user_name: ENV[SENDGRID_USERNAME],
    password: ENV[SENDGRID_PASSWORD],
    authentication: :plain,
    domain: 'sinatraform.herokuapp.com/'
  }
end

def validate_email_params
  param :name,    String, required: true, min_length: 3, max_length: 250
  param :email,   String, required: true, format: email_format
  param :message, String, required: true, min_length: 500
end

def email_format
  /^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$/
end
