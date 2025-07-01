module SpreeAdyen
  module StoreControllerDecorator
    def self.prepended(base)
      base.helper SpreeAdyen::BaseHelper
    end
  end
end

Spree::StoreController.prepend(SpreeAdyen::StoreControllerDecorator) if defined?(Spree::StoreController)
