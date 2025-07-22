module SpreeAdyen
  module PaymentSources
    class Unknown < ::Spree::PaymentSource
      store_accessor :public_metadata

      def actions
        %w[]
      end

      def self.display_name
        'Unknown'
      end

      def display_payment_info
        'Unknown'
      end
    end
  end
end
