module SpreeAdyen
  module PaymentSessions
    class Create
      def initialize(order:, user:, amount:, payment_method:)
        @order = order
        @amount = amount
        @user = user
        @payment_method = payment_method
      end

      def call
        response = payment_method.create_payment_session(amount, order)
        return unless response.success?

        PaymentSession.create!(
          adyen_id: response.params['id'],
          order: order,
          amount: amount,
          adyen_data: response.params['sessionData'],
          user: user,
          expires_at: response.params['expiresAt'],
          payment_method: payment_method
        )
      end

      attr_reader :order, :payment_method, :amount, :user
    end
  end
end
