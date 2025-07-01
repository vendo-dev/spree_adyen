module SpreeAdyen
  module PaymentSessions
    class RequestPayloadSerializer
      DEFAULT_PARAMS = {
        channel: 'Web'
      }.freeze

      def initialize(order:, amount:, user:)
        @order = order
        @amount = amount
        @user = user
      end

      def to_h
        {
          amount: {
            value: amount,
            currency: order.currency
          },
          returnUrl: return_url,
          reference: order.number,
          countryCode: order.billing_address.country.iso,
          merchantAccount: merchant_account,
          shopperEmail: shopper_email,
          shopperReference: user&.id || shopper_email,
          expiresAt: expires_at
        }.merge!(DEFAULT_PARAMS)
      end

      private

      attr_reader :order, :amount, :user

      def return_url
        Settings.spree_adyen.return_url
      end

      def shopper_email
        @shopper_email ||= user&.email || order.email
      end

      # should it be in spree store metadata key?
      def merchant_account
        Settings.spree_adyen.merchant_account
      end

      def expires_at
        DateTime.current + Settings.spree_adyen.session_timeout_minutes.minutes
      end
    end
  end
end