module SpreeAdyen
  module PaymentSources
    class Base < ::Spree::PaymentSource
      self.abstract_class = true
    end
  end
end
