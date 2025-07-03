module SpreeAdyen
  class CreatePayment
    def initialize(payment_session:, event:)
      @payment_session = payment_session
      @event = event
    end

    def call
      create_source
      create_payment
    end

    private

    attr_reader :payment_session, :event, :source

    def create_source
      @source = SpreeAdyen::Sources::Create.new(
        payment_session: payment_session,
        event: event
      ).call
    end

    def create_payment
      # sometimes a job is re-tried and creates a double payment record so we need to avoid it!
      order.payments.find_or_initialize_by(
        payment_method_id: payment_session.payment_method_id,
        response_code: event.psp_reference,
        amount: payment_session.amount
      ).tap do |payment|
        payment.source = source if source.present?
        payment.save!
      end
    end
  end
end
