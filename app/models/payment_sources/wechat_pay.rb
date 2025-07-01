module SpreeAdyen
  module PaymentSources
    class WechatPay < ::Spree::PaymentSource
      store_accessor :public_metadata, :buyer_id, :buyer_logon_id, :trade_no

      def actions
        %w[credit void]
      end

      def self.display_name
        'WeChat Pay'
      end

      def display_buyer_info
        "WeChat Pay: #{buyer_logon_id}"
      end
    end
  end
end 