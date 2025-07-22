module SpreeAdyen
  module PaymentSources
    class Alma < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'Alma'
      end

      def display_payment_info
        'Alma'
      end
    end
  end
end
