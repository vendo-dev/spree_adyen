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

        Create.new(order: order, user: user, amount: amount, payment_method: payment_method).call
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
