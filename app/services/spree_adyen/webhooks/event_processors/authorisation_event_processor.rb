module SpreeAdyen
  module Webhooks
    module EventProcessors
      class AuthorisationEventProcessor
        def initialize(event)
          @event = event
        end

        def call
          Rails.logger.info("[adyen-webhook][#{event_id}]: Started processing")
          payment_session = SpreeAdyen::PaymentSession.find_by!(adyen_id: event.session_id)
          source = SpreeAdyen::Webhooks::Actions::CreateSource.new(event: event, payment_session: payment_session).call
          order = payment_session.order

          order.with_lock do
            # create or find payment
            # atm payment should already created for web channel (but there is no payment for mobile channels)
            payment = Spree::Payment.find_or_create_by(
              response_code: payment_session.adyen_id,
              payment_method: payment_session.payment_method,
              amount: order.total_minus_store_credits,
              order: order
            ).tap { |payment| payment.skip_source_requirement = true }
            payment.update!(source: source, state: 'processing')
            if event.success?
              payment.complete! if payment.processing?
              payment_session.complete
              Spree::Dependencies.checkout_complete_service.constantize.call(order: order) unless order.completed?
            else
              payment.failure!
              payment_session.refuse
              if order.complete?
                Rails.error.unexpected('Payment failed for previously completed order', context: { order_id: order.id, event: event.payload },
                                                                                        source: 'spree_adyen')
              end
            end
          end
          Rails.logger.info("[adyen-webhook][#{event_id}]: Finished processing")
        end

        private

        attr_reader :event

        delegate :id, to: :event, prefix: true
      end
    end
  end
end
