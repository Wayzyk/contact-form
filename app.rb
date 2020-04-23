require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/param'
require 'pony'
require 'recaptcha'
require 'pry-byebug'
require 'rubocop'

include Recaptcha::Adapters::ControllerMethods
include Recaptcha::Adapters::ViewMethods

Recaptcha.configure do |config|
  config.site_key  = '6Le7oRETAAAAAETt105rjswZ15EuVJiF7BxPROkY'
  config.secret_key = '6Le7oRETAAAAAL5a8yOmEdmDi3b2pH7mq5iH1bYK'
end

helpers Sinatra::Param

get '/' do
  erb :create, layout: :layout
end

post '/' do
  begin
    if !verify_recaptcha(action: 'email')
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
    to: "contact-us@example.com",
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
    address: 'smtp.gmail.com',
    port: '587',
    user_name: 'user',
    password: 'password',
    authentication: :plain,
    domain: 'localhost.localdomain'
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
