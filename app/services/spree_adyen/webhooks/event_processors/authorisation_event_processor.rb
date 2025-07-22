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
            handle_failure
          end
        end

        private

        attr_reader :event

        delegate :order, to: :payment_session

        def handle_success
          create_payment_source
          complete_order unless order.completed?
        end

        def create_payment_source
          payment = order.payments.find_or_initialize_by(response_code: event.psp_reference)
          payment.source ||= SpreeAdyen::Webhooks::Actions::CreateSource.new(event: event).call
          payment.save!
        end

        def handle_failure
          # TODO: Implement
        end

        def payment_session
          @payment_session ||= SpreeAdyen::PaymentSession.find_by!(adyen_id: event.session_id)
        end
      end
    end
  end
end
