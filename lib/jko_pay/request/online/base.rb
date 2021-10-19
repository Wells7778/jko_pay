# frozen_string_literal: true
require 'faraday'
require 'json'
require 'digest'
require 'openssl'
require 'jko_pay/request/base'

module JkoPay
  module Request
    module Online
      class Base < ::JkoPay::Request::Base

        def store_id= store_id
          @store_id = store_id.to_s
        end

        def platform_order_id= platform_order_id
          @platform_order_id = platform_order_id.to_s
        end

        def request
          res = send_request request_action
          response_klass.new(JSON.parse(res.body), res)
        end

        private

        def to_hash
          hash = {
            platform_order_id: @platform_order_id,
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
          raise JkoPay::Error, "Missing API Key" unless config.merchant_key.present?
          raise JkoPay::Error, "Missing Secret Key" unless config.merchant_secret.present?
          params = {
            store_id: @config.merchant_id,
            **to_hash,
          }
          headers = {
            "Content-Type" => "application/json",
            "API-KEY" => config.merchant_key,
            "DIGEST" => sign_params(params),
          }
          body = JSON.dump(params)
          Faraday.post("#{request_host}/#{path}", body, headers)
        end

        def sign_params params
          OpenSSL::HMAC.hexdigest("SHA256", @config.merchant_secret, JSON.dump(params))
        end

      end
    end
  end
end