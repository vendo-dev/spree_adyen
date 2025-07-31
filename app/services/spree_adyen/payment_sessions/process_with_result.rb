module SpreeAdyen
  module PaymentSessions
    class ProcessWithResult
      def initialize(payment_session:, session_result:)
        @payment_session = payment_session
        @session_result = session_result
      end

      def call
        payment = order.payments.build(
          amount: payment_session.amount,
          payment_method: payment_session.payment_method,
          response_code: payment_session.adyen_id,
          source: nil,
          state: 'processing',
          skip_source_requirement: true
        )

        status = payment_session.payment_method.payment_session_result(payment_session.adyen_id, session_result).params.fetch('status')

        order.with_lock do
          case status
          when 'completed'
            payment_session.complete!
            payment.complete!
            Spree::Dependencies.checkout_complete_service.constantize.call(order: order)
          when 'canceled'
            payment.void!
            payment_session.cancel!
          when 'refused', 'expired'
            payment.failure!
            payment_session.refuse!
          when 'paymentPending'
            payment_session.pending!
            payment.save!
          end
        end
      end

      private

      attr_reader :payment_session, :session_result

      delegate :order, to: :payment_session
    end
  end
end
