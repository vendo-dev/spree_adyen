module SpreeAdyen
  module PaymentSources
    class Kakaopay < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'KakaoPay'
      end

      def display_payment_info
        "KakaoPay: #{payment_reference}"
      end
    end
  end
end
