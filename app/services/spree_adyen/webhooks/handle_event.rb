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
        Rails.logger.info("[adyen-webhook][#{event_id}]: Event received")
        # event not supported - skip
        return unless event.code.in?(EVENT_HANDLERS.keys)

        Rails.logger.info("[adyen-webhook][#{event_id}]: Event queued")
        EVENT_HANDLERS[event.code].set(wait: SpreeAdyen::Config.webhook_delay_in_seconds.seconds)
                                  .perform_later(event.payload)
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

      delegate :id, to: :event, prefix: true
    end
  end
end
