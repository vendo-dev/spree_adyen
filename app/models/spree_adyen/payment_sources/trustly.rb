module SpreeAdyen
  module PaymentSources
    class Trustly < Base
      store_accessor :public_metadata

      def actions
        %w[credit void]
      end

      def self.display_name
        'Trustly'
      end
    end
  end
end
