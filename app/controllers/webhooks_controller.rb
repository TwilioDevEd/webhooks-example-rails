require 'twilio-ruby'
class WebhooksController < ApplicationController
  # Before we allow the incoming request to connect, verify
  # that it is a Twilio request
  before_filter :authenticate_twilio_request

  # Voice Request URL - receives incoming calls from Twilio
  def voice
    # Customize the message to the caller's phone number
    from_number = params[:From]

    # create a new TwiML response
    response = Twilio::TwiML::VoiceResponse.new do |r|
      # <Say> a message to the caller
      r.say "Thanks for calling! Your phone number is #{from_number}. I got your call because of Twilio's webhook. Goodbye!", :voice => 'alice', :language => 'en-gb'
    end
    render text: response.to_s
  end

  # SMS Request URL - receives incoming messages from Twilio
  def message
    # Customize the message with length of the incoming message
    msg_length = params[:Body].length

    # <Message> a text bac to the person who texted us
    response = Twilio::TwiML::MessagingResponse.new do |r|
      r.sms  "Your text to me was #{msg_length} characters long. Webhooks are neat :)"
    end

    # Return the TwiML
    render text: response.to_s
  end


  # Authenticate that all requests to our public-facing TwiML pages are
  # coming from Twilio. Adapted from the example at
  # http://twilio-ruby.readthedocs.org/en/latest/usage/validation.html
  # Read more on Twilio Security at https://www.twilio.com/docs/security
  private
  def authenticate_twilio_request
    twilio_signature = request.headers['HTTP_X_TWILIO_SIGNATURE']

    # Helper from twilio-ruby to validate requests.
    @validator = Twilio::Util::RequestValidator.new ENV['TWILIO_AUTH_TOKEN']

    # the POST variables attached to the request (eg "From", "To")
    # Twilio requests only accept lowercase letters. So scrub here:
    post_vars = params.reject {|k, v| k.downcase == k}
    puts post_vars

    is_twilio_req = @validator.validate(request.url, post_vars, twilio_signature)

    unless is_twilio_req
      render :xml => (Twilio::TwiML::Response.new {|r| r.hangup}).to_s, :status => :unauthorized
      false
    end
  end

end
