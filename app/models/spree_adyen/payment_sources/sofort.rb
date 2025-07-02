module SpreeAdyen
  module PaymentSources
    class Sofort < ::Spree::PaymentSource
      store_accessor :public_metadata, :bank_code, :country_code, :bic, :iban

      def actions
        %w[credit]
      end

      def self.display_name
        'SOFORT'
      end

      def display_bank_info
        "Bank: #{bank_code} (#{country_code})"
      end
    end
  end
end
