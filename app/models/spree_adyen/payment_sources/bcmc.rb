module SpreeAdyen
  module PaymentSources
    class Bcmc < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'Bancontact card'
      end

      def display_payment_info
        'Bancontact card'
      end
    end
  end
end
