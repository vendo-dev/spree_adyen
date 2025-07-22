module SpreeAdyen
  module PaymentSources
    class AlipayHk < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'AlipayHK'
      end

      def display_payment_info
        'AlipayHK'
      end
    end
  end
end
