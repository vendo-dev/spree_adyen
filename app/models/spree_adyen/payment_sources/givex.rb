module SpreeAdyen
  module PaymentSources
    class Givex < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'Givex'
      end

      def display_payment_info
        "Givex: #{payment_reference}"
      end
    end
  end
end
