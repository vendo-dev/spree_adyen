module SpreeAdyen
  module OrderDecorator
    def self.prepended(base)
      base.has_many :adyen_payment_sessions, class_name: 'SpreeAdyen::PaymentSession', dependent: :destroy
    end
  end
end

Spree::Order.prepend(SpreeAdyen::OrderDecorator)
