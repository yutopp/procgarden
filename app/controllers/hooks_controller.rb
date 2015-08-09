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
    case params['type']
    when 'profile_update'
      logger.info("factory_hook: profile_update")
      BridgeFactoryAndCage::FactoryBridge.instance.load_profiles()

    when 'package_update'
      logger.info("factory_hook: package_update")
      Thread.start do
        begin
          res = BridgeFactoryAndCage::CagesBridge.instance.update_all_nodes()
          raise "Failed to update all nodes" if res == false
          logger.info "factory_hook: package_update / finished"

        rescue => e
          logger.error "factory_hook: Exception at package_update / #{e}"
        end
      end

    else
      raise "factory_hook: type #{params['type']} is not supported"
    end

    render json: {
             ok: true,
           }

    rescue => e
      logger.error "factory_hook: Exception / #{e}"
      render json: {
               ok: false,
               error: e.to_s,
             }, status: 500
  end
end
