module SpreeAdyen
  module PaymentSources
    class Paypal < ::Spree::PaymentSource
      store_accessor :public_metadata, :payer_id, :payer_email, :payment_id

      def actions
        %w[credit void]
      end

      def self.display_name
        'PayPal'
      end

      def display_payer_info
        "PayPal: #{payer_email}"
      end
    end
  end
end 