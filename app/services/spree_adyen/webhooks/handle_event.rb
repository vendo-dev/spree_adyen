module SpreeAdyen
  module Webhooks
    class HandleEvent
      EVENT_HANDLERS = {
        'AUTHORISATION' => SpreeAdyen::Webhooks::ProcessAuthorisationEventJob
      }.freeze

      def initialize(raw_data:)
        @raw_data = raw_data
      end

      def call
        # event not supported - skip
        return unless event.code.in?(EVENT_HANDLERS.keys)

        # EVENT_HANDLERS[event.code].perform_later(event.payload)
        SpreeAdyen::Webhooks::EventProcessors::AuthorisationEventProcessor.new(event).call
      end

      def event
        @event ||= SpreeAdyen::Webhooks::Event.new(event_data: parsed_event_data)
      end

      def parsed_event_data
        JSON.parse(raw_data)
      rescue JSON::ParserError => e
        Rails.logger.error("Failed to parse event data: #{raw_data}")
        raise e
      end

      private

      attr_reader :raw_data
    end
  end
end
