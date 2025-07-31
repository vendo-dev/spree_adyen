module SpreeAdyen
  module Payments
    class RequestPayloadPresenter
      DEFAULT_PARAMS = {
        recurringProcessingModel: 'UnscheduledCardOnFile',
        shopperInteraction: 'ContAuth'
      }.freeze

      def initialize(source:, amount_in_cents:, gateway_options:)
        @source = source
        @amount_in_cents = amount_in_cents
        @gateway_options = gateway_options.with_indifferent_access
      end

      def to_h
        {
          metadata: {
            spree_payment_method_id: source.payment_method_id, # this is needed to validate hmac in webhooks controller
            spree_order_id: order_number
          },
          amount: {
            value: amount_in_cents,
            currency: currency
          },
          paymentMethod: {
            type: 'scheme',
            storedPaymentMethodId: source.gateway_payment_profile_id
          },
          reference: gateway_options[:order_id],
          shopperReference: shopper_reference,
          channel: SpreeAdyen::Config.channel,
          merchantAccount: source.payment_method.preferred_merchant_account
        }.merge!(DEFAULT_PARAMS)
      end

      private

      attr_reader :source, :amount_in_cents, :gateway_options

      delegate :currency, to: :order
      delegate :user, to: :order, allow_nil: true

      # we need to send reference even for guest users, otherwise we can't tokenize the card
      def shopper_reference
        if user.present?
          "customer_#{user.id}"
        else
          "guest_#{order_number}"
        end
      end

      def order_number
        @order_number ||= gateway_options[:order_id].split('-').first
      end

      def order
        @order ||= Spree::Order.find_by!(number: order_number)
      end
    end
  end
end
