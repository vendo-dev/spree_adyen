module SpreeAdyen
  module PaymentSources
    class Paysafecard < Base
      store_accessor :public_metadata

      def actions
        %w[credit void]
      end

      def self.display_name
        'PaySafeCard'
      end
    end
  end
end
