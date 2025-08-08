module SpreeAdyen
  module CustomDomainDecorator
    def self.prepended(base)
      base.after_create :add_allowed_origin
    end

    def add_allowed_origin
      return if store.adyen_gateway.blank?

      SpreeAdyen::AddAllowedOrigin.perform_later(url, store.adyen_gateway.id)
    end
  end
end

Spree::CustomDomain.prepend(SpreeAdyen::CustomDomainDecorator)
