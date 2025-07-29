module SpreeAdyen
  module Webhooks
    module Errors
      class FailureForCompleteOrder < StandardError
        MESSAGE = 'Payment failed for previously completed order with id: '.freeze

        def initialize(order_id:)
          @order_id = order_id

          super(message)
        end

        def message
          MESSAGE + order_id.to_s
        end

        private

        attr_reader :order_id
      end
    end
  end
end
