module SpreeAdyen
  module Webhooks
    class Event
      def initialize(event_data:)
        @event_data = event_data
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

      def payment_method
        @payment_method ||= body['paymentMethod']
      end

      def card_details
        @card_details ||= additional_data.slice('expiryDate', 'cardSummary').transform_keys(&:underscore)
      end

      def session_id
        @session_id ||= body.dig('additional_data', 'checkoutSessionId')
      end

      def event_date
        @event_date ||= body['eventDate'].to_datetime
      end

      private

      attr_reader :event_data

      def body
        @body ||= event_data['notificationItems'][0]['NotificationRequestItem']
      end

      def psp_reference
        @psp_reference ||= body['pspReference']
      end

      def additional_data
        @additional_data ||= body.fetch('additionalData', {})
      end
    end
  end
end
