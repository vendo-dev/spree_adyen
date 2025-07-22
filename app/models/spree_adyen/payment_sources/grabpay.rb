module SpreeAdyen
  module PaymentSources
    class Grabpay < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'GrabPay'
      end

      def display_payment_info
        "GrabPay: #{payment_reference}"
      end
    end
  end
end
