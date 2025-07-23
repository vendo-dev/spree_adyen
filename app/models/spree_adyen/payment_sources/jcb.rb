module SpreeAdyen
  module PaymentSources
    class Jcb < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_reference

      def actions
        %w[credit void capture]
      end

      def self.display_name
        'JCB'
      end

      def display_payment_info
        "JCB: #{payment_reference}"
      end
    end
  end
end
