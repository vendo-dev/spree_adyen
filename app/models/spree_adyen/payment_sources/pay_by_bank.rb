module SpreeAdyen
  module PaymentSources
    class PayByBank < Base
      store_accessor :public_metadata, :bank

      def actions
        %w[credit void]
      end

      def self.display_name
        'Pay by Bank Europe'
      end
    end
  end
end
