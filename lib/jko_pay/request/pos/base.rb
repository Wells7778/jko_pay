# frozen_string_literal: true
require 'net/https'
require 'json'
require 'digest'

require 'jko_pay/request/base'

module JkoPay
  module Request
    module Pos
      class Base < ::JkoPay::Request::Base
        PRODUCTION_HOST = 'https://uat-pos.jkopay.app'
        SANDBOX_HOST = 'https://uat-pos.jkopay.app/Test'

        def store_id= store_id
          @store_id = store_id.to_s
        end

        def store_name= store_name
          @store_name = store_name.to_s
        end

        def merchant_trade_number= merchant_trade_number
          @merchant_trade_number = merchant_trade_number.to_s
        end

        def pos_id= pos_id
          @pos_id = pos_id.to_s
        end

        def pos_trade_time= pos_trade_time
          if pos_trade_time.instance_of? String
            @pos_trade_time = pos_trade_time
          else
            @pos_trade_time = pos_trade_time.strftime("%Y/%m/%d %H:%M:%S")
          end
        end

        def request
          res = send_request request_action
          response_klass.new(JSON.parse(res.body), res)
        end

        private

        def to_hash
          hash = {
            StoreID: @store_id,
            StoreName: @store_name,
            MerchantTradeNo: @merchant_trade_number,
            PosID: @pos_id,
            PosTradeTime: @pos_trade_time,
          }
          hash
        end

        def request_host
          @config.production? ? PRODUCTION_HOST : SANDBOX_HOST
        end

        def request_action
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def response_klass
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def send_request path
          uri = URI("#{request_host}/#{path}")
          req = Net::HTTP::Post.new(uri)
          req['Content-Type'] = 'application/json'
          body = JSON.dump(sign_params)
          req.body = body
          Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http|
            http.request(req)
          }
        end

        def sign_params
          params = {
            MerchantID: @config.merchant_id,
            SendTime: Time.current.strftime("%Y%m%d%H%M%S"),
            **to_hash,
          }
          params["Sign"] = Digest::SHA1.hexdigest("#{params.to_json}#{@config.merchant_key}")
          params
        end

      end
    end
  end
end