module SpreeAdyen
  module PaymentSources
    class Klarna < ::Spree::PaymentSource
      store_accessor :public_metadata, :payment_method_type, :authorization_token, :session_id

      def actions
        %w[credit void]
      end

      def self.display_name
        'Klarna'
      end

      def display_payment_info
        "Klarna: #{payment_method_type}"
      end

      def payment_method_type_display
        case payment_method_type
        when 'paynow'
          'Pay Now'
        when 'paylater'
          'Pay Later'
        when 'slice_it'
          'Slice It'
        else
          payment_method_type&.titleize
        end
      end
    end
  end
end 