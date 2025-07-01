module SpreeAdyen
  module PaymentApi
    class Base
      def initialize(client: nil)
        @client = client || SpreeAdyen::PaymentApi::Client.new.call
      end

      private

      attr_reader :client

      def handle_response
        response = yield
        return response if response.status == 201

        handle_error(response)
      rescue Adyen::PermissionError, Adyen::AuthenticationError => e
        handle_error(e)
      end

      def handle_failure(response)
        raise SpreeAdyen::PaymentApi::Error.new(status: response.status, message: response.response)
      end

      def handle_error(error)
        raise SpreeAdyen::PaymentApi::Error.new(status: error.status, message: error.message)
      end
    end
  end
end 