module SpreeAdyen
  module PaymentSessions
    class ProcessWithResult
      def initialize(payment_session:, session_result:)
        @payment_session = payment_session
        @session_result = session_result
      end

      def call
        build_payment
        payment.started_processing!

        update_resources_with_status
      end

      private

      attr_reader :payment_session, :session_result, :payment

      delegate :order, to: :payment_session

      def update_resources_with_status
        case status
        when 'completed'
          payment_session.complete!
          payment.complete!
          complete_order
        when 'canceled'
          payment.void!
          payment_session.cancel!
        when 'refused', 'expired'
          payment.failure!
          payment_session.refuse!
        when 'paymentPending'
          payment_session.pending!
        end
      end

      def status
        status_response.params.fetch('status')
      end

      def build_payment
        @payment = order.payments.build(
          amount: payment_session.amount,
          payment_method: payment_session.payment_method,
          response_code: payment_session.adyen_id,
          source: nil,
          skip_source_requirement: true
        )
      end

      def complete_order
        Spree::Dependencies.checkout_complete_service.constantize.call(order: order)
      end

      def status_response
        @status_response ||= payment_session.payment_method.payment_session_result(payment_session.adyen_id, session_result)
      end
    end
  end
end
