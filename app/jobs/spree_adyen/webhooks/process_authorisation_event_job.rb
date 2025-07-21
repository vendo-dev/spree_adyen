module Spree
  module Webhooks
    class ProcessAuthorisationEventJob < SpreeAdyen::BaseJob
      def perform(payload)
        event = SpreeAdyen::Webhooks::Event.new(payload)
        SpreeAdyen::Webhooks::EventProcessors::AuthorisationEventProcessor.new(event).call
      end
    end
  end
end
