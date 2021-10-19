require 'active_support/ordered_options'
module JkoPay
  class Config

    attr_accessor :host
    attr_accessor :merchant_id
    attr_accessor :merchant_key
    attr_accessor :merchant_secret
    attr_accessor :platform
    attr_accessor :mode

    def initialize
      @host = nil
      @merchant_id = nil
      @merchant_key = nil
      @merchant_secret = nil
      @platform = nil
      @mode = :sandbox
    end

    def production?
      @mode == :production
    end


  end
end