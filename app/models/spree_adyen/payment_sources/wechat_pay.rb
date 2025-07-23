module SpreeAdyen
  module PaymentSources
    class WechatPay < Base
      store_accessor :public_metadata

      def actions
        %w[credit void]
      end

      def self.display_name
        'WeChat Pay'
      end
    end
  end
end
