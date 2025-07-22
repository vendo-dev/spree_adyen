module SpreeAdyen
  module PaymentSources
    class KcpNaverpay < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'Naverpay'
      end

      def display_payment_info
        "Naverpay: #{payment_reference}"
      end
    end
  end
end
