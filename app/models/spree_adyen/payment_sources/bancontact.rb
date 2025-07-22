module SpreeAdyen
  module PaymentSources
    class Bancontact < ::Spree::PaymentSource
      store_accessor :public_metadata, :bank_code, :card_number

      def actions
        %w[credit]
      end

      def self.display_name
        'Bancontact'
      end

      def display_card_info
        "Card: #{card_number} (Bank: #{bank_code})"
      end
    end
  end
end
