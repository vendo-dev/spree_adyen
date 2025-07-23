module SpreeAdyen
  module PaymentSources
    class OnlineBankingCzechRepublic < Base
      store_accessor :public_metadata, :bank

      def actions
        %w[credit void]
      end

      def self.display_name
        'Online Banking Czech Republic'
      end
    end
  end
end
