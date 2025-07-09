module SpreeAdyen
  # use this serializer to configure the Adyen Drop-in component
  # https://docs.adyen.com/online-payments/build-your-integration/sessions-flow/?platform=Web&integration=Drop-in&version=6.18.1&tab=embed_script_and_stylesheet_1_2#configure
  class CheckoutSerializer
    def initialize(payment_session)
      @payment_session = payment_session
    end

    def to_json
      @to_json ||= to_h.to_json
    end

    def to_h
      @to_h ||= {
        session: {
          id: payment_session.adyen_id,
          sessionData: payment_session.adyen_data
        },
        environment: payment_session.payment_method.environment,

        amount: {
          value: Spree::Money.new(payment_session.amount, currency: currency).cents,
          currency: currency
        },
        countryCode: payment_session.order.bill_address.country_iso,
        locale: 'en-US',
        clientKey: payment_session.payment_method.preferred_client_key,
        showPayButton: false,
      }
    end

    private

    attr_reader :payment_session

    delegate :currency, to: :payment_session
  end
end 