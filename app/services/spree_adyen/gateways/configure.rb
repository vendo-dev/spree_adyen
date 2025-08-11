module SpreeAdyen
  module Gateways
    class Configure
      def initialize(gateway)
        @gateway = gateway
      end

      def call
        gateway.preferred_client_key = configuration.client_key || gateway.generate_client_key.params['clientKey']
        gateway.preferred_merchant_account = configuration.merchant_account

        set_up_allowed_origins

        set_up_webhook_with_hmac_key unless current_webhook_is_valid?

        gateway
      end

      private

      attr_reader :gateway

      def set_up_allowed_origins
        gateway.stores.each do |store|
          SpreeAdyen::AddAllowedOriginJob.perform_later(store.id, gateway.id, 'store')
          store.custom_domains.each do |custom_domain|
            SpreeAdyen::AddAllowedOriginJob.perform_later(custom_domain.id, gateway.id, 'custom_domain')
          end
        end
      end

      def configuration
        @configuration ||= SpreeAdyen::Gateways::Configuration.new(
          gateway.get_api_credential_details.params
        )
      end

      def current_webhook_is_valid?
        gateway.preferred_webhook_id.present? &&
          gateway.preferred_hmac_key.present? &&
          gateway.test_webhook.success?
      end

      def set_up_webhook_with_hmac_key
        webhook_url = URI.parse(Spree::Core::Engine.routes.url_helpers.adyen_webhooks_url(host: gateway.stores.first.url))
        webhook_url.scheme = 'https'
        set_up_webhook_request = gateway.set_up_webhook(webhook_url.to_s)
        if set_up_webhook_request.success?
          gateway.preferred_webhook_id = set_up_webhook_request.params['id']
          generate_hmac_key_request = gateway.generate_hmac_key
          if generate_hmac_key_request.success?
            gateway.previous_hmac_key = gateway.preferred_hmac_key if gateway.preferred_hmac_key.present?
            gateway.preferred_hmac_key = generate_hmac_key_request.params['hmacKey']
          else
            gateway.errors.add(:base, "Failed to generate HMAC key for webhook. Response: #{generate_hmac_key_request.message}")
          end
        else
          gateway.errors.add(:base, "Failed to set up webhook. Response: #{set_up_webhook_request.message}")
        end
      end
    end
  end
end
