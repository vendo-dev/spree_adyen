module SpreeAdyen
  module PaymentSessions
    class FindOrCreate
      DEFAULT_STATUS = 'pending'

      def initialize(order:, user:, amount:, payment_method:)
        @order = order
        @amount = amount
        @user = user
        @payment_method = payment_method
      end

      def call
        return payment_session if payment_session.present?

        response = payment_method.create_payment_session(amount, order)

        PaymentSession.create!(
          adyen_id: response.params['id'],
          order: order,
          amount: amount,
          currency: order.currency,
          user: user,
          expires_at: response.params['expiresAt'],
          status: DEFAULT_STATUS,
          payment_method: payment_method
        )
      end

      private

      attr_reader :order, :payment_method, :amount, :user

      def payment_session
        @payment_session ||= PaymentSession.pending.not_expired.find_by(
          payment_method: payment_method,
          order: order,
          user: user,
          amount: amount
        )
      end
    end
  end
end
