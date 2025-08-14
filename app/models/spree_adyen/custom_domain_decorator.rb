module SpreeAdyen
  module CustomDomainDecorator
    def self.prepended(base)
      base.after_commit :add_allowed_origin

      base.store_accessor :private_metadata, :adyen_allowed_origin_id
      base.store_accessor :private_metadata, :adyen_allowed_origin_url
    end

    def add_allowed_origin
      return if store.adyen_gateway.blank?

      SpreeAdyen::AddAllowedOriginJob.perform_later(id, store.adyen_gateway.id, 'custom_domain')
    end
  end
end

Spree::CustomDomain.prepend(SpreeAdyen::CustomDomainDecorator)
