module SpreeAdyen
  module PaymentSources
    class SepaDirectDebit < ::Spree::PaymentSource
      store_accessor :public_metadata, :iban, :bic, :account_holder_name, :mandate_id

      def actions
        %w[credit]
      end

      def self.display_name
        'SEPA Direct Debit'
      end

      def display_account_info
        "Account: #{iban} (#{account_holder_name})"
      end

      def masked_iban
        return iban if iban.blank?
        
        "#{iban[0..3]}****#{iban[-4..-1]}"
      end
    end
  end
end 