module SpreeAdyen
  module PaymentSessions
    class ProcessWithResult
      def initialize(payment_session:, session_result:)
        @payment_session = payment_session
        @session_result = session_result
      end

      def call
        case status
        when 'completed'
          payment_session.complete!
          create_payment
          complete_order
        when 'canceled' then payment_session.cancel!
        when 'refused' then payment_session.refuse!
        when 'paymentPending'
          payment_session.pending!
        end
      end

      private

      attr_reader :payment_session, :session_result

      delegate :order, to: :payment_session

      def status
        status_response.params.fetch('status')
      end

      def create_payment
        order.payments.build(
          amount: payment_session.amount,
          payment_method: payment_session.payment_method,
          response_code: payment_session.id,
          source: nil,
          state: 'completed'
        ).tap do |payment|
          payment.skip_source_requirement = true
          payment.save!
        end
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
