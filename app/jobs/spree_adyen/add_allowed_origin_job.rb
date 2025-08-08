module SpreeAdyen
  class AddAllowedOriginJob < SpreeAdyen::BaseJob
    ALREADY_EXISTS_ERROR_CODE = '31_004'

    def perform(url, gateway_id)
      allowed_origin = URI::HTTPS.build(host: url).to_s
      gateway = SpreeAdyen::Gateway.find(gateway_id)
      response = gateway.add_allowed_origin(allowed_origin)

      if response.success?
        Rails.logger.info("[SpreeAdyen][AddAllowedOriginJob]: Origin #{allowed_origin} added to gateway #{gateway_id}")
      elsif response.message['errorCode'] == ALREADY_EXISTS_ERROR_CODE
        Rails.logger.warn("[SpreeAdyen][AddAllowedOriginJob]: Origin #{allowed_origin} already exists")
      else
        Rails.error.unexpected('Cannot create allowed origin', context: { url: allowed_origin, gateway_id: gateway_id }, source: 'spree_adyen')
      end
    end
  end
end