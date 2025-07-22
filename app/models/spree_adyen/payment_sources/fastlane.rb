module SpreeAdyen
  module PaymentSources
    class Fastlane < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'Fastlane by Paypal'
      end

      def display_payment_info
        "Fastlane by Paypal: #{payment_reference}"
      end
    end
  end
end
