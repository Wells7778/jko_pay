# frozen_string_literal: true
require "jko_pay/version"
require "jko_pay/configure"

require "jko_pay/request"
require "jko_pay/response"

module JkoPay
  class Error < StandardError; end

    # Example Setup For Rails initializer
    # JkoPay.setup do |config|
    #   # setting for default
    #   config.online.host = 'online pay host'
    #   config.online.merchant_key = 'online pay API-KEY'
    #   config.online.merchant_secret = 'online pay Sign secret'
    #   config.pos.host = 'pos pay host'
    #   config.pos.merchant_id = 'MID'
    #   config.pos.merchant_secret = 'KEY'
    #   config.setup_weiby do |c|
    #     # setting for platform weiby
    #     c.online.host = 'online pay host'
    #     c.online.merchant_key = 'online pay API-KEY'
    #     c.online.merchant_secret = 'online pay Sign secret'
    #     c.pos.host = 'pos pay host'
    #     c.pos.merchant_id = 'MID'
    #     c.pos.merchant_secret = 'KEY'
    #   end
    # end

    def self.setup
      yield config
    end

    def self.config
      @config ||= JkoPay::Configure.new
    end

end
