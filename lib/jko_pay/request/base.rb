require "jko_pay/config"
module JkoPay
  module Request
    class Base

      def initialize params=nil
        return unless params.is_a? Hash
        params.each_pair do |key, value|
          send "#{key}=", value
        end
      end

      def configure conf
        @config = conf
        set_config
      end

      def config
        @config ||= JkoPay::Config.new
      end

      def set_config
        config_name = self.class.name.split("::")[-2].underscore
        current_config = JkoPay.config.send(config_name.to_sym)
        if config.production?
          current_config = nil
          [config.platform, config_name.to_sym].compact.each do |name|
            current_config = (current_config || JkoPay.config).send(name.to_sym)
          end
        end
        config.host ||= current_config.host
        config.merchant_id ||= current_config.merchant_id
        config.merchant_key ||= current_config.merchant_key
        config.merchant_secret ||= current_config.merchant_secret
      end

      def request
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def request_host
        config.host
      end

    end
  end
end