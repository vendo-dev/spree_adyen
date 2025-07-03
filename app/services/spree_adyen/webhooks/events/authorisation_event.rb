module SpreeAdyen
  module Webhooks
    module Events
      class AuthorisationEvent
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

        def handle_success
          SpreeAdyen::CompleteOrder.new(payment_session: payment_session, event: event).call
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
