module SpreeAdyen
  module BaseHelper
    def current_adyen_gateway
      @current_adyen_gateway ||= current_store.adyen_gateway
    end

    def current_adyen_payment_intent
      return if current_adyen_gateway.nil?

      @current_adyen_payment_intent ||= SpreeStripe::CreatePaymentIntent.new.call(@order, current_adyen_gateway)
    end
  end
end
