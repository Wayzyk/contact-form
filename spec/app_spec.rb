# frozen_string_literal: true

require File.expand_path 'spec_helper.rb', __dir__

describe 'Sinatra Feedback application' do
  context 'get root' do
    it 'should return 200 status' do
      get '/'
      expect(last_response).to be_ok
    end

    it 'should render index page' do
      get '/'
      expect(last_response.body).to include(
        '<form method="POST" data-url="/" id="contact_form">'
      )
    end

    it 'should render layout' do
      get '/'
      expect(last_response.body).to include(
        '<title>Contact Form</title>'
      )
    end
  end

  context 'post ' do
    it 'should validate email params presence' do
      post '/'
      expect(last_response.body).to eql 'Parameter is required'
    end

    it 'should validate email params' do
      post '/', name: 'sm',
                email: 'smth', message: 'smth'
      expect(last_response.body).to eql(
        'Parameter cannot have length less than 3'
      )

      post '/', name: 'smth',
                email: 'smth', message: 'smth'
      expect(last_response.body).to include('Parameter must match format')

      post '/', name: 'smth',
                email: 'example@example.com', message: 'smth'
      expect(last_response.body).to eql(
        'Parameter cannot have length less than 500'
      )

      post '/', name: 'a' * 251,
                email: 'example@example.com', message: 'a' * 500
      expect(last_response.body).to eql(
        'Parameter cannot have length greater than 250'
      )
    end

    it 'shoould call Pony.mail' do
      expect(Pony).to receive(:mail)
      post '/', name: 'smth',
                email: 'example@example.com', message: 'a' * 500
    end
  end
end
