module SpreeAdyen
  module PaymentSessions
    class Create
      def initialize(order:, user: nil, amount:)
        @order = order
        @amount = amount
        @user = user || order.user
      end

      def call
        send_request
        PaymentSession.create!(order: order, amount: amount, adyen_id: response.id)
      end

      private

      attr_reader :order, :payment_method, :amount

      def send_request
        PaymentApi::Sessions::Create.new(payload: request_payload).call
      end

      def request_payload
        @request_payload ||= RequestPayloadSerializer.new(order: order, amount: amount, user: user).to_h
      end
    end
  end
end