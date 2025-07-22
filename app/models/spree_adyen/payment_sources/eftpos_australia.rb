module SpreeAdyen
  module PaymentSources
    class EftposAustralia < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void]
      end

      def self.display_name
        'eftpos'
      end

      def display_payment_info
        "eftpos: #{payment_reference}"
      end
    end
  end
end
