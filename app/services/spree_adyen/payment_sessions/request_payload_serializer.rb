module SpreeAdyen
  module PaymentSessions
    class RequestPayloadSerializer
      TIMEOUT_IN_MINUTES = 60
      DEFAULT_PARAMS = {
        channel: 'Web'
      }.freeze

      def initialize(order:, amount:, user:, merchant_account:)
        @order = order
        @amount = amount
        @user = user
        @merchant_account = merchant_account
      end

      def to_h
        {
          amount: {
            value: amount,
            currency: order.currency
          },
          returnUrl: return_url,
          reference: order.number, # payment id
          countryCode: order.billing_address.country.iso,
          lineItems: line_items,
          merchantAccount: merchant_account,
          merchantOrderReference: order.number,
          expiresAt: expires_at,
          allowedPaymentMethods: allowed_payment_methods,
          additionalData: { spree_order_id: order.id }
        }.merge!(shopper_details, DEFAULT_PARAMS)
      end

      private

      attr_reader :order, :amount, :user, :merchant_account

      def allowed_payment_methods
        %w[blik visa mastercard]
      end

      def shopper_details
        {
          shopperName: {
            firstName: order.bill_address.firstname,
            lastName: order.bill_address.lastname
          },
          shopperEmail: shopper_email,
          shopperReference: format('%03d', order.user_id) # min 3 digits
        }
      end

      def line_items
        order.line_items.map do |line_item|
          {
            amountExcludingTax: Money.new(line_item.price - line_item.included_tax_total, order.currency).cents,
            amountIncludingTax: Money.new(line_item.price + line_item.additional_tax_total, order.currency).cents,
            description: line_item.variant.name,
            id: line_item.id,
            sku: line_item.variant.sku,
            quantity: line_item.quantity
          }
        end
      end

      def return_url
        "https://#{Rails.application.routes.default_url_options[:host]}/adyen/payment_sessions"
      end

      def shopper_email
        @shopper_email ||= user&.email || order.email
      end

      def expires_at
        TIMEOUT_IN_MINUTES.minutes.from_now.iso8601
      end
    end
  end
end
