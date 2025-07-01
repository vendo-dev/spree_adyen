module SpreeAdyen
  module PaymentApi
    class Client
      def call
        Adyen::Client.new.tap do |client|
          client.api_key = Settings.stripe_adyen.api_key
          client.env = Settings.stripe_adyen.environment.to_sym
        end
      end
    end
  end
end