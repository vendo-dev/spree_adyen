module SpreeAdyen
  module PaymentSources
    class CashAppAfterpay < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'Cash App Afterpay'
      end

      def display_payment_info
        'Cash App Afterpay'
      end
    end
  end
end
