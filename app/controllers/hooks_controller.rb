require 'openssl'

class HooksController < ApplicationController
  protect_from_forgery except: [:factory_hook]

  def factory_hook
    payload = request.raw_post
    secret = if Rails.env.production? then
               ENV['TORIGOYA_HOOK_SECRET']
             else
               "10101"
             end

    expected_sig = OpenSSL::HMAC.hexdigest("sha1", secret, payload)
    factory_sig = request.headers["X-Torigoya-Factory-Signature"]

    raise "invalid signature" if expected_sig != factory_sig

    # success
    logger.info("factory_hook recieved. payload => #{payload}")

    # TODO: implement message deliver

    render json: {
             ok: true,
           }

  rescue => e
    render json: {
             ok: false,
             error: e.to_s,
           }, status: 500
  end
end
