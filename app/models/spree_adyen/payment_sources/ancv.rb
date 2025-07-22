module SpreeAdyen
  module PaymentSources
    class Ancv < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'ANCV'
      end

      def display_payment_info
        'ANCV'
      end
    end
  end
end
