module SpreeAdyen
  module PaymentSources
    class BankTransfer < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'Bank transfer'
      end

      def display_payment_info
        'Bank transfer'
      end
    end
  end
end
