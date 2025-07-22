module SpreeAdyen
  module PaymentSources
    class BcmcMobile < ::Spree::PaymentSource
      def actions
        %w[credit void]
      end

      def self.display_name
        'Bancontact mobile'
      end

      def display_payment_info
        'Bancontact mobile'
      end
    end
  end
end
