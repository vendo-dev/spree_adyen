module SpreeAdyen
  module PaymentSources
    class Bizum < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'Bizum'
      end

      def display_payment_info
        'Bizum'
      end
    end
  end
end
