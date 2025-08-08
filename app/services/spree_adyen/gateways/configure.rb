module SpreeAdyen
  module Gateways
    class Configure
      def initialize(gateway)
        @gateway = gateway
      end

      def call
        gateway.preferred_client_key = configuration.client_key || gateway.generate_client_key.params['clientKey']
        gateway.preferred_merchant_account = configuration.merchant_account

        (domains - configuration.allowed_origins).each do |domain|
          SpreeAdyen::AddAllowedOriginJob.perform_later(domain, gateway.id)
        end
        
        set_up_webhook unless current_webhook_is_valid?
      ensure
        gateway.save!
      end

      private

      attr_reader :gateway

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

      def domains
        @domains ||= gateway.stores.each_with_object([]) do |store, acc|
          acc << store.url
          acc.concat(store.custom_domains.pluck(:url))
        end.uniq
      end

      def set_up_webhook
        payload = {
          active: true,
          communicationFormat: 'json',
          url: Spree::Core::Engine.routes.url_helpers.adyen_webhooks_url(host: gateway.stores.first.url),
          description: "Webhook created by SpreeAdyen on #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
        }
        set_up_webhook_request = gateway.set_up_webhook(payload)
        return unless set_up_webhook_request.success?

        gateway.preferred_webhook_id = set_up_webhook_request.params['id']
        gateway.preferred_hmac_key = gateway.generate_hmac_key.params['hmacKey']
      end
    end
  end
end
