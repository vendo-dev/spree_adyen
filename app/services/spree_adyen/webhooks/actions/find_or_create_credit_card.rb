module SpreeAdyen
  module Webhooks
    module Actions
      class FindOrCreateCreditCard
        def initialize(event:, gateway:)
          @event = event
          @gateway = gateway
        end

        def call
          gateway.credit_cards.capturable.find_or_create_by(find_by_hash) do |cc|
            cc.assign_attributes(credit_card_attributes)
            cc.user = payment_session.user
            cc.payment_method = gateway
          end
        end

        private

        attr_reader :event, :gateway

        def payment_session
          @payment_session ||= SpreeAdyen::PaymentSession.find_by!(adyen_id: event.session_id)
        end

        def credit_card_attributes
          @credit_card_attributes ||= SpreeAdyen::Webhooks::CreditCardPresenter.new(event).to_h
        end

        def find_by_hash
          credit_card_attributes.slice(:gateway_payment_profile_id).compact
        end
      end
    end
  end
end
