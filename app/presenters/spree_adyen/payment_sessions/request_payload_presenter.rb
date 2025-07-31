module SpreeAdyen
  module PaymentSessions
    class RequestPayloadPresenter
      DEFAULT_PARAMS = {
        recurringProcessingModel: 'UnscheduledCardOnFile',
        shopperInteraction: 'Ecommerce',
        storePaymentMethodMode: 'enabled'
      }.freeze

      def initialize(order:, amount:, user:, merchant_account:, payment_method:)
        @order = order
        @amount = amount
        @user = user
        @merchant_account = merchant_account
        @payment_method = payment_method
      end

      def to_h
        {
          metadata: {
            spree_payment_method_id: payment_method.id, # this is needed to validate hmac in webhooks controller
            spree_order_id: order_number
          },
          amount: {
            value: Spree::Money.new(amount, currency: currency).cents,
            currency: currency
          },
          returnUrl: return_url,
          channel: SpreeAdyen::Config.channel,
          reference: order_number,
          countryCode: address.country_iso,
          lineItems: line_items,
          merchantAccount: merchant_account,
          merchantOrderReference: order_number,
          expiresAt: expires_at
        }.merge!(shopper_details, DEFAULT_PARAMS)
      end

      private

      attr_reader :order, :amount, :user, :merchant_account, :payment_method

      delegate :number, to: :order, prefix: true
      delegate :currency, to: :order

      def shopper_details
        {
          shopperName: {
            firstName: address.firstname,
            lastName: address.lastname
          },
          shopperEmail: order.email,
          shopperReference: shopper_reference
        }
      end

      # we need to send reference even for guest users, otherwise we can't tokenize the card
      def shopper_reference
        if user.present?
          "customer_#{user.id}"
        else
          "guest_#{order.number}"
        end
      end

      def address
        @address ||= order.bill_address || order.ship_address
      end

      def line_items
        order.line_items.map do |line_item|
          {
            amountExcludingTax: Spree::Money.new(line_item.price - line_item.included_tax_total, currency: currency).cents,
            amountIncludingTax: Spree::Money.new(line_item.price + line_item.additional_tax_total, currency: currency).cents,
            description: line_item.name,
            id: line_item.id,
            sku: line_item.sku,
            quantity: line_item.quantity
          }
        end
      end

      def return_url
        Spree::Core::Engine.routes.url_helpers.redirect_adyen_payment_session_url(host: order.store.url)
      end

      def expires_at
        SpreeAdyen::Config.payment_session_expiration_in_minutes.minutes.from_now.iso8601
      end
    end
  end
end
