module SpreeAdyen
  module Webhooks
    class Event
      def initialize(event_data:)
        @event_data = event_data.deep_stringify_keys
      end

      def payload
        event_data
      end

      def code
        @code ||= body['eventCode']
      end

      def success?
        body['success'] == 'true'
      end

      def billing_address
        @billing_address ||= begin
          return {} unless additional_data['billingAddress']

          SpreeAdyen::AddressPresenter.new(additional_data['billingAddress']).to_h
        end
      end

      def shipping_address
        @shipping_address ||= begin
          return {} unless additional_data['deliveryAddress']

          SpreeAdyen::AddressPresenter.new(additional_data['deliveryAddress']).to_h
        end
      end

      def payment_method_reference
        @payment_method_reference ||= body['paymentMethod'].to_sym
      end

      def stored_payment_method_id
        @stored_payment_method_id ||= additional_data['tokenization.storedPaymentMethodId']
      end

      def card_details
        @card_details ||= additional_data.slice('expiryDate', 'cardSummary', 'type')
      end

      def merchant_reference
        @merchant_reference ||= body['merchantReference']
      end

      def session_id
        @session_id ||= additional_data['checkoutSessionId']
      end

      def event_date
        @event_date ||= body['eventDate'].to_datetime
      end

      def psp_reference
        @psp_reference ||= body['pspReference']
      end

      private

      attr_reader :event_data

      def body
        @body ||= event_data['notificationItems'][0]['NotificationRequestItem']
      end

      def additional_data
        @additional_data ||= body.fetch('additionalData', {})
      end
    end
  end
end
