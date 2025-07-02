module SpreeAdyen
  module PaymentSessions
    class UpdateWithResult
      def initialize(payment_session:, session_result:)
        @payment_session = payment_session
        @session_result = session_result
      end

      def call
        payment_session.tap do |record|
          record.update!(status: status_response.fetch('status'))
        end
      end

      private

      attr_reader :payment_session, :session_result

      def status_response
        payment_session.payment_method.check_payment_session_status(payment_session.adyen_id, session_result)
      end
    end
  end
end
