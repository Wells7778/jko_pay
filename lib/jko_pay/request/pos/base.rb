# frozen_string_literal: true
require 'faraday'
require 'json'
require 'digest'

require 'jko_pay/request/base'

module JkoPay
  module Request
    module Pos
      class Base < ::JkoPay::Request::Base

        attr_accessor :request_raw, :response_raw

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
          @response_raw = res.body
          raise Error, "status: #{res.status}, message: #{res.body}" if res.status != 200

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
            GatewayTradeNo: "",
          }
          hash
        end

        def request_action
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def response_klass
          raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
        end

        def send_request path
          raise JkoPay::Error, "Api host url is not presence" unless request_host.present?
          raise JkoPay::Error, "Missing Merchant ID" unless config.merchant_id.present?
          raise JkoPay::Error, "Missing Merchant Key" unless config.merchant_key.present?
          body = sign_params
          @request_raw = JSON.dump(body.sort.to_h)
          Faraday.post("#{request_host}/#{path}", @request_raw, {"Content-Type" => "application/json"})
        end

        def sign_params
          params = {
            MerchantID: config.merchant_id,
            SendTime: Time.current.strftime("%Y%m%d%H%M%S"),
            **to_hash,
          }.as_json

          data_string = params.sort.to_h.to_json
          data_string += config.merchant_key
          params["Sign"] = Digest::SHA256.hexdigest(data_string).upcase
          params
        end

      end
    end
  end
end