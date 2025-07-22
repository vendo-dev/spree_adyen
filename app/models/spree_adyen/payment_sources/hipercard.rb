module SpreeAdyen
  module PaymentSources
    class Hipercard < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'Hipercard'
      end

      def display_payment_info
        "Hipercard: #{payment_reference}"
      end
    end
  end
end
