module SpreeAdyen
  module Webhooks
    class CreditCardPresenter
      def initialize(event, payment_session)
        @event = event
        @payment_session = payment_session
      end

      def to_h
        {
          name: event.card_details['type'],
          month: event.card_details['expiry_date']&.split('/')&.first,
          year: event.card_details['expiry_date']&.split('/')&.last,
          cc_type: event.payment_method,
          last_digits: event.card_details['card_summary'],
          payment_method: payment_session.payment_method,
          gateway_customer_profile_id: event.payload.dig('notificationItems', 0, 'NotificationRequestItem', 'merchantReference'),
          gateway_payment_profile_id: event.additional_data['storedPaymentMethodId']
        }

      private

      attr_reader :event, :payment_session
    end
  end
end 