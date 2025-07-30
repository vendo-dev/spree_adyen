module SpreeAdyen
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :validate_hmac!

    def create
      SpreeAdyen::Webhooks::HandleEvent.new(event_payload: webhook_params).call

      head :ok
    end

    private

    def validate_hmac!
      event = SpreeAdyen::Webhooks::Event.new(event_data: webhook_params)
      gateway = SpreeAdyen::Gateway.find(event.payment_method_id)
      return if Adyen::Utils::HmacValidator.new.valid_webhook_hmac?(
        webhook_params.dig('notificationItems', 0, 'NotificationRequestItem'),
        gateway.preferred_hmac_key
      )

      Rails.logger.error("[adyen-webhook][#{event.id}]: Failed to validate hmac")

      head :unauthorized
    end

    def webhook_params
      params.require(:webhook).permit(
        :live,
        notificationItems: [{ NotificationRequestItem: {} }]
      )
    end
  end
end
