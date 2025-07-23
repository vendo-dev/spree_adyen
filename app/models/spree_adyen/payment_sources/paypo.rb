module SpreeAdyen
  module PaymentSources
    class Paypo < Base
      store_accessor :public_metadata

      def actions
        %w[credit void]
      end

      def self.display_name
        'PayPo'
      end
    end
  end
end
