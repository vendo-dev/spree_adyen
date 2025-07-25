module SpreeAdyen
  module Webhooks
    module Errors
      # jobs that raises the error that inherits from this class should be retried
      class RetryError < StandardError
      end
    end
  end
end
