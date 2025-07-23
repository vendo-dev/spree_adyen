module SpreeAdyen
  module PaymentSources
    class SepaDirectDebit < Base
      store_accessor :public_metadata

      def actions
        %w[credit void capture]
      end

      def self.display_name
        'SEPA Direct Debit'
      end
    end
  end
end
