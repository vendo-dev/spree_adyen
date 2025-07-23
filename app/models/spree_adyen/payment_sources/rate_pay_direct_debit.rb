module SpreeAdyen
  module PaymentSources
    class RatePayDirectDebit < Base
      store_accessor :public_metadata

      def actions
        %w[credit void capture]
      end

      def self.display_name
        'Ratepay Direct debit'
      end
    end
  end
end
