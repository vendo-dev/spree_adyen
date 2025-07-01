module SpreeAdyen
  module PaymentApi
    class Error < StandardError
      def initialize(response)
        @status = response.status
        @response = response.response
      end

      def message
        "AdyenAPI responds with #{status} status code"
      end

      def description
        "API response: #{response.inspect}"
      end

      private

      attr_reader :response, :status
    end 
  end
end