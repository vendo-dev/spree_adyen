module SpreeAdyen
  module PaymentSources
    class Riverty < Base
      store_accessor :public_metadata

      def actions
        %w[credit void capture]
      end

      def self.display_name
        'Riverty'
      end
    end
  end
end
