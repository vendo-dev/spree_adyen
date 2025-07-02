module SpreeAdyen
  module PaymentSources
    class GooglePay < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_data, :payment_method, :transaction_identifier

      def actions
        %w[credit void]
      end

      def self.display_name
        'Google Pay'
      end

      def display_payment_info
        "Google Pay: #{payment_method}"
      end
    end
  end
end
