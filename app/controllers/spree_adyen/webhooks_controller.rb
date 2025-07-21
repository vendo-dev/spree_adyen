module SpreeAdyen
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :validate_hmac!

    def create
      SpreeAdyen::EventHandler::ParseEvent.new(request.body.read).call

      head :ok
    end

    private

    def validate_hmac!
      return if hmac_keys.any? do |key|
        params.require(:webhook)[:notificationItems].all? do |item|
          Adyen::Utils::HmacValidator.new.valid_webhook_hmac?(item, key)
        end
      end

      # TODO: log failed hmac validation

      head :unauthorized
    end

    def permitted_params
      params.require(:webhook)
    end

    # https://docs.adyen.com/development-resources/webhooks/verify-hmac-signatures/
    # If you generate a new HMAC key, make sure that you can still accept webhooks signed with your previous HMAC key for some time, because:
    # - It can take some time to propagate the new key in our infrastructure.
    # - HMAC signatures are calculated when the webhook payload is generated, so any webhook events queued before you saved the new key are signed using your previous key.
    def hmac_keys
      [ENV['ADYEN_WEBHOOK_HMAC_1'], ENV['ADYEN_WEBHOOK_HMAC_2']]
    end
  end
end
