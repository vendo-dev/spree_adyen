module SpreeAdyen
  module PaymentSources
    class EftDirectdebitCa < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'PAD Canada'
      end

      def display_payment_info
        "PAD Canada: #{payment_reference}"
      end
    end
  end
end
