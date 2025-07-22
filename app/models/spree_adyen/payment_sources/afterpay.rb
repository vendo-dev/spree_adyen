module SpreeAdyen
  module PaymentSources
    class Afterpay < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'Afterpay'
      end

      def display_payment_info
        'Afterpay'
      end
    end
  end
end
