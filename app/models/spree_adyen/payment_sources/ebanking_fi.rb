module SpreeAdyen
  module PaymentSources
    class EbankingFi < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'Online Banking Finland'
      end

      def display_payment_info
        "Online Banking Finland: #{payment_reference}"
      end
    end
  end
end
