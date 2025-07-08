module SpreeAdyen
  module PaymentSessions
    class UpdateWithResult
      def initialize(payment_session:, session_result:)
        @payment_session = payment_session
        @session_result = session_result
      end

      def call
        case status
        when 'completed' then payment_session.complete!
        when 'canceled' then payment_session.cancel!
        when 'refused' then payment_session.refuse!
        end
      end

      private

      attr_reader :payment_session, :session_result

      def status
        status_response.params.fetch('status')
      end

      def status_response
        payment_session.payment_method.payment_session_result(payment_session.adyen_id, session_result)
      end
    end
  end
end