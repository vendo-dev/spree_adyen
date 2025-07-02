module SpreeAdyen
  module PaymentSources
    class Alipay < ::Spree::PaymentSource
      store_accessor :public_metadata, :buyer_id, :buyer_logon_id, :trade_no

      def actions
        %w[credit void]
      end

      def self.display_name
        'Alipay'
      end

      def display_buyer_info
        "Alipay: #{buyer_logon_id}"
      end
    end
  end
end
