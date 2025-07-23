module SpreeAdyen
  module PaymentSources
    class SamsungPay < Base
      store_accessor :public_metadata

      def actions
        %w[credit void capture]
      end

      def self.display_name
        'Samsung Pay'
      end
    end
  end
end
