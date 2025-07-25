module SpreeAdyen
  module Webhooks
    module Errors
      class PaymentNotFound < RetryError
      end
    end
  end
end
