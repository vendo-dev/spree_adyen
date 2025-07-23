module SpreeAdyen
  module PaymentSources
    class Paypal < Base
      store_accessor :public_metadata

      def actions
        %w[credit void capture]
      end

      def self.display_name
        'PayPal'
      end
    end
  end
end
