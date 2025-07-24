module SpreeAdyen
  module Webhooks
    module EventProcessors
      class AuthorisationEventProcessor
        def initialize(event)
          @event = event
        end

        def call
          if event.success?
            handle_success
          else
            payment.failure!
          end
        end

        private

        attr_reader :event

        delegate :order, to: :payment_session

        def handle_success
          payment.update!(source: SpreeAdyen::Webhooks::Actions::CreateSource.new(event: event).call)
          complete_order unless order.completed?
        end

        def payment
          order.payments.find_by!(response_code: payment_session.adyen_id)
        rescue ActiveRecord::RecordNotFound
          # it is possible that the payment is not created yet, so we should retry the job
          raise "Payment with response code #{payment_session.adyen_id} not found, retrying the job"
        end

        def payment_session
          @payment_session ||= SpreeAdyen::PaymentSession.find_by!(adyen_id: event.session_id)
        end
      end
    end
  end
end
