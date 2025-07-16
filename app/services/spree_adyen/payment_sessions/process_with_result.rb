module SpreeAdyen
  module PaymentSessions
    class ProcessWithResult
      BRAND_MAP = {
        'mc' => 'master'
      }.freeze

      def initialize(payment_session:, session_result:)
        @payment_session = payment_session
        @session_result = session_result
      end

      def call
        case status
        when 'completed'
          payment_session.complete!
          create_payment
          complete_order
        when 'canceled' then payment_session.cancel!
        when 'refused' then payment_session.refuse!
        when 'paymentPending'
          payment_session.pending!
          # create_payment
        end
      end

      private

      attr_reader :payment_session, :session_result

      delegate :order, to: :payment_session

      def status
        status_response.params.fetch('status')
      end

      def create_payment
        Spree::Payment.create!(
          order: order,
          amount: payment_session.amount,
          source: nil,
          payment_method: payment_session.payment_method,
          response_code: payment_session.id,
          state: 'completed'
        )
      end

      def payment_data
        @payment_data ||= status_response.params.fetch('payments', [])[0]
      end

      def credit_card
        return unless %w[googlepay scheme].include?(payment_data.fetch('paymentMethod')['type'])

        Spree::CreditCard.find_or_create_by!(
          payment_method_id: payment_session.payment_method_id,
          gateway_payment_profile_id: additional_data.fetch('tokenization.storedPaymentMethodId')
        ) do |new_credit_card|
          new_credit_card.cc_type = mapped_brand_name
        end
      end

      def additional_data
        @additional_data ||= status_response.params['additionalData'] || {}
      end

      def complete_order
        Spree::Dependencies.checkout_complete_service.constantize.call(order: order)
      end

      def mapped_brand_name
        response_brand = additional_data['paymentMethod']
        BRAND_MAP.fetch(response_brand, response_brand)
      end

      def status_response
        @status_response ||= payment_session.payment_method.payment_session_result(payment_session.adyen_id, session_result)
      end
    end
  end
end
