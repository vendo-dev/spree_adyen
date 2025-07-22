module SpreeAdyen
  module PaymentSources
    class Boleto < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'Boleto Bancário'
      end

      def display_payment_info
        'Boleto Bancário'
      end
    end
  end
end
