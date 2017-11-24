class WebhookController < ApplicationController
  ## Lineからのcallbackか認証
  #protect_from_forgery with: :null_session
  protect_from_forgery :except => [:callback]
  #protect_from_forgery with: :callback
  

  #CHANNEL_SECRET = ENV['CHANNEL_SECRET']
  CHANNEL_SECRET = "f6696a7a71b5ccfdcc86cbe16ffb8748"
  #OUTBOUND_PROXY = ENV['OUTBOUND_PROXY']
  OUTBOUND_PROXY = "http:/fixie:IMU9EMNelvSiOef@velodrome.usefixie.com:80"
  
  #CHANNEL_ACCESS_TOKEN = ENV['CHANNEL_ACCESS_TOKEN']
  CHANNEL_ACCESS_TOKEN = "i+90zzq0VNOfefDOBwooX6NTlFXPj6Z5VvL+7YAkcl70lLsi3nV2Rpgmwd12tGz49ojLsJiVGhrT9fDEdDbHKsblfXrW06CAiW/R4QCB13PvPSOpcCubq4XUrQYQRludfNwyeeBmH7CYOayBmUG6bAdB04t89/1O/w1cDnyilFU="

  def callback
    unless is_validate_signature
      p "error"
      return
      #render :nothing => true, status: 470
    end
    p "Non error"

    event = params["events"][0]
    event_type = event["type"]
    replyToken = event["replyToken"]

    case event_type
    when "message"
      input_text = event["message"]["text"]
      output_text = input_text
    end

    client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    res = client.reply(replyToken, output_text)

    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end

    render :nothing => true, status: :ok
  end

  private
  # verify access from LINE
  def is_validate_signature
    signature = request.headers["X-LINE-Signature"]
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
    p "hash"
    signature_answer = Base64.strict_encode64(hash)
    signature == signature_answer
  end
end
