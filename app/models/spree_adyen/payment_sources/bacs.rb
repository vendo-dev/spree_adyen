module SpreeAdyen
  module PaymentSources
    class Bacs < ::Spree::PaymentSource
      def actions
        %w[credit void capture]
      end

      def self.display_name
        'BACS Direct Debit'
      end

      def display_payment_info
        'BACS Direct Debit'
      end
    end
  end
end
