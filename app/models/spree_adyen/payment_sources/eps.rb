module SpreeAdyen
  module PaymentSources
    class Eps < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'EPS'
      end

      def display_payment_info
        "EPS: #{payment_reference}"
      end
    end
  end
end
