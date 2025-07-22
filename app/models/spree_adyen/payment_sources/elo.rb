module SpreeAdyen
  module PaymentSources
    class Elo < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'Elo'
      end

      def display_payment_info
        "Elo: #{payment_reference}"
      end
    end
  end
end
