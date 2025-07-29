module SpreeAdyen
  module Webhooks
    module EventProcessors
      class AuthorisationEventProcessor
        def initialize(event)
          @event = event
        end

        def call
          payment.started_processing!
          payment.update!(source: SpreeAdyen::Webhooks::Actions::CreateSource.new(event: event).call)

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
          payment.complete! if payment.processing?
          complete_order unless order.completed?
        end

        def handle_failure
          payment.failure!
          return unless order.completed?

          raise SpreeAdyen::Webhooks::Errors::FailureForCompleteOrder.new(order_id: order.id)
        end

        def complete_order
          Spree::Dependencies.checkout_complete_service.constantize.call(order: order)
        end

        def payment
          @payment ||= order.payments.first_or_initialize(
            response_code: payment_session.adyen_id,
            payment_method: payment_session.payment_method,
            amount: order.total_minus_store_credits,
            order: order
          ).tap do |payment|
            payment.skip_source_requirement = true
          end
        end

        def payment_session
          @payment_session ||= SpreeAdyen::PaymentSession.find_by!(adyen_id: event.session_id)
        end
      end
    end
  end
end
