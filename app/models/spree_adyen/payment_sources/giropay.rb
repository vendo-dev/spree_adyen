module SpreeAdyen
  module PaymentSources
    class Giropay < ::Spree::PaymentSource
      store_accessor :public_metadata, :bank_code, :bic, :account_number

      def actions
        %w[credit]
      end

      def self.display_name
        'Giropay'
      end

      def display_bank_info
        "Bank: #{bank_code} (BIC: #{bic})"
      end
    end
  end
end
