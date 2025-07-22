module SpreeAdyen
  module PaymentSources
    class Benefit < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'BENEFIT'
      end

      def display_payment_info
        'BENEFIT'
      end
    end
  end
end
