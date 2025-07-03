module SpreeAdyen
  module PaymentSessions
    class FindOrCreate
      DEFAULT_STATUS = 'pending'.freeze

      def initialize(order:, user:, amount:, payment_method:)
        @order = order
        @amount = amount
        @user = user
        @payment_method = payment_method
      end

      def call
        return payment_session if payment_session.present?

        payment_method.create_payment_session(order: order, amount: amount, user: user)

        PaymentSession.create!(
          adyen_id: response.id,
          order: order,
          amount: amount,
          user: user,
          expires_at: response.expires_at,
          status: DEFAULT_STATUS,
          payment_method: payment_method
        )
      end

      private

      attr_reader :order, :payment_method, :amount, :user

      delegate :response, to: :send_request

      def payment_session
        @payment_session ||= PaymentSession.pending.not_expired.find_by(
          payment_method: payment_method,
          order: order,
          user: user
        )
      end
    end
  end
end
