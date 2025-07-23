module SpreeAdyen
  module PaymentSources
    class Clearpay < ::Spree::PaymentSource
      def actions
        %w[credit void capture]
      end

      def self.display_name
        'Clearpay'
      end

      def display_payment_info
        'Clearpay'
      end
    end
  end
end
