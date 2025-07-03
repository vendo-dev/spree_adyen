module SpreeAdyen
  module Webhooks
    class Event
      def initialize(event_data:)
        @event_data = event_data
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

          additional_data['billingAddress'].transform_keys(&:underscore)
        end
      end

      def shipping_address
        @shipping_address ||= begin
          return {} unless additional_data['deliveryAddress']

          additional_data['deliveryAddress'].transform_keys(&:underscore)
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

      def body
        @body ||= event_data['notificationItems'][0]['NotificationRequestItem']
      end

      def additional_data
        @additional_data ||= body['additionalData']
      end
    end
  end
end
