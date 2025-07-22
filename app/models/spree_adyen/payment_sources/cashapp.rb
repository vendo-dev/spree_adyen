module SpreeAdyen
  module PaymentSources
    class Cashapp < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'Cash App Pay'
      end

      def display_payment_info
        'Cash App Pay'
      end
    end
  end
end
