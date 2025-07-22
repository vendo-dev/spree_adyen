module SpreeAdyen
  module StoreDecorator
    def adyen_gateway
      @adyen_gateway ||= payment_methods.adyen.active.last
    end
  end
end

Spree::Store.prepend(SpreeAdyen::StoreDecorator)
