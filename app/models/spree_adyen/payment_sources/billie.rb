module SpreeAdyen
  module PaymentSources
    class Billie < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'Billie'
      end

      def display_payment_info
        'Billie'
      end
    end
  end
end
