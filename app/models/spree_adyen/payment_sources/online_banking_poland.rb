module SpreeAdyen
  module PaymentSources
    class OnlineBankingPoland < Base
      store_accessor :public_metadata, :bank

      def actions
        %w[credit void]
      end

      def self.display_name
        'Online Banking Poland'
      end
    end
  end
end
