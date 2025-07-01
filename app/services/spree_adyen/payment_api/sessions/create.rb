module SpreeAdyen
  module PaymentApi
    module Sessions
      class Create < SpreeAdyen::PaymentApi::Base
        def initialize(payload:, client: nil)
          @payload = payload

          super(client: client)
        end

        def call
          handle_failure do
            client.checkout.payments_api.sessions(payload, headers: { 'Idempotency-Key' => SecureRandom.uuid })
          end
        end

        private

        attr_reader :payload
      end
    end
  end
end