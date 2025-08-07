module SpreeAdyen
  module Gateways
    class Configure
      def initialize(gateway)
        @gateway = gateway
      end

      def call
        set_up_client_key
        add_allowed_origin
      end

      def set_up_client_key
        generated_api_key = gateway.generate_client_key.response['clientKey']
        gateway.preferred_client_key = generated_api_key
      end

      def add_allowed_origin
        return if allowed_origins.include?(current_domain)

        gateway.add_allowed_origin(current_domain)
      end

      def allowed_origins
        @allowed_origins ||= gateway.get_allowed_origins.response['data'].map { |origin| origin['domain'] }
      end

      def current_domain
        @current_domain ||= Rails.application.routes.default_url_options[:host]
      end
    end
  end
end
