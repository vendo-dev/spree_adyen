module SpreeAdyen
  module StoreDecorator
    def stripe_gateway
      @stripe_gateway ||= payment_methods.adyen.active.last
    end
  end
end

Spree::Store.prepend(SpreeAdyen::StoreDecorator)
