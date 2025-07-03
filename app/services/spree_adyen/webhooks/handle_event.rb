module SpreeAdyen
  module Webhooks
    class HandleEvent
      EVENT_HANDLERS = {
        'AUTHORISATION' => SpreeAdyen::Webhooks::Events::AuthorisationEvent
      }.freeze

      def initialize(event_data:)
        @event = SpreeAdyen::Webhooks::Event.new(event_data)
      end

      def call
        # event not supported - skip
        return if event.code.not_in?(EVENT_HANDLERS.keys)

        # TODO: - not for now - this should be processed in job
        EVENT_HANDLERS[event.code].new(event).call
      end

      private

      attr_reader :event
    end
  end
end
