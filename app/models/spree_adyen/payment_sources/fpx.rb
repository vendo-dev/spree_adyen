module SpreeAdyen
  module PaymentSources
    class Fpx < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'FPX Online banking Malaysia'
      end

      def display_payment_info
        "FPX Online banking Malaysia: #{payment_reference}"
      end
    end
  end
end
