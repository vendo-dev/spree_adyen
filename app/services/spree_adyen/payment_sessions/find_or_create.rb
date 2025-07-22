module SpreeAdyen
  module PaymentSessions
    class FindOrCreate
      def initialize(order:, user:, amount:, payment_method:)
        @order = order
        @amount = amount
        @user = user
        @payment_method = payment_method
      end

      def call
        return payment_session if payment_session.present?

        response = payment_method.create_payment_session(amount, order)
        return unless response.success?

        PaymentSession.create!(
          adyen_id: response.params['id'],
          order: order,
          amount: amount,
          currency: order.currency,
          adyen_data: response.params['sessionData'],
          user: user,
          expires_at: response.params['expiresAt'],
          payment_method: payment_method
        )
      end

      private

      attr_reader :order, :payment_method, :amount, :user

      def payment_session
        @payment_session ||= PaymentSession.with_status(:initial).not_expired.find_by(
          payment_method: payment_method,
          order: order,
          user: user,
          amount: amount
        )
      end
    end
  end
end
