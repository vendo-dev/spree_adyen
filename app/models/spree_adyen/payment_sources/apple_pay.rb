module SpreeAdyen
  module PaymentSources
    class ApplePay < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_data, :payment_method, :transaction_identifier

      def actions
        %w[credit void]
      end

      def self.display_name
        'Apple Pay'
      end

      def display_payment_info
        "Apple Pay: #{payment_method}"
      end
    end
  end
end
