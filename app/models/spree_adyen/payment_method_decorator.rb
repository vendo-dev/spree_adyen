module SpreeAdyen
  module PaymentMethodDecorator
    STRIPE_TYPE = 'SpreeAdyen::Gateway'.freeze

    def self.prepended(base)
      base.scope :adyen, -> { where(type: ADYEN_TYPE) }
    end

    def adyen?
      type == STRIPE_TYPE
    end
  end
end

Spree::PaymentMethod.prepend(SpreeAdyen::PaymentMethodDecorator)
