module SpreeAdyen
  module PaymentSources
    class GrabpayPaylater < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'GrabPay PayLater'
      end

      def display_payment_info
        "GrabPay PayLater: #{payment_reference}"
      end
    end
  end
end
