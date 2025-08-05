module SpreeAdyen
  class Gateway < ::Spree::Gateway
    preference :merchant_account, :string
    preference :api_key, :password
    preference :client_key, :password
    preference :hmac_key, :password
    preference :test_mode, :boolean, default: true

    has_many :payment_sessions, class_name: 'SpreeAdyen::PaymentSession',
                                foreign_key: 'payment_method_id',
                                dependent: :delete_all,
                                inverse_of: :payment_method

    # @param amount_in_cents [Integer] the amount in cents to capture
    # @param payment_source [Spree::CreditCard | Spree::PaymentSource]
    # @param gateway_options [Hash] this is an instance of Spree::Payment::GatewayOptions.to_hash
    def purchase(amount_in_cents, payment_source, gateway_options = {})
      payload = SpreeAdyen::Payments::RequestPayloadPresenter.new(
        source: payment_source,
        amount_in_cents: amount_in_cents,
        gateway_options: gateway_options
      ).to_h

      response = send_request do
        client.checkout.payments_api.payments(payload, headers: { 'Idempotency-Key' => SecureRandom.uuid })
      end
      response_body = response.response

      if response.status.to_i == 200
        success(response_body.pspReference, response_body)
      else
        failure(response_body.slice('pspReference', 'message').values.join(' - '))
      end
    end

    def cancel(payment)
      transaction_id = payment.response_code
      if payment.completed?
        amount = payment.credit_allowed
        return success(transaction_id, {}) if amount.zero?
        # Don't create a refund if the payment is for a shipment, we will create a refund for the whole shipping cost instead
        return success(transaction_id, {}) if payment.respond_to?(:for_shipment?) && payment.for_shipment?

        refund = payment.refunds.create!(
          amount: amount,
          reason: Spree::RefundReason.order_canceled_reason,
          refunder_id: payment.order.canceler_id
        )

        # Spree::Refund#response has the response from the `credit` action
        # For the authorization ID we need to use the payment.response_code
        # Otherwise we'll overwrite the payment authorization with the refund ID
        success(transaction_id, refund.response.params)
      else
        payment.void!
        success(transaction_id, {})
      end
    end

    def credit(amount_in_cents, _source, payment_id, _gateway_options = {})
      payment = Spree::Payment.find_by(response_code: payment_id)
      payload = SpreeAdyen::RefundPayloadPresenter.new(
        payment: payment,
        amount_in_cents: amount_in_cents,
        payment_method: self,
        currency: payment.currency
      ).to_h

      response = send_request do
        client.checkout.modifications_api.refund_captured_payment(payload, payment_id, headers: { 'Idempotency-Key' => SecureRandom.uuid })
      end

      success(response.response['pspReference'], response)
    end

    def capture(amount_in_cents, payment_session_id, _gateway_options = {})
      raise NotImplementedError
    end

    def void(response_code, source, gateway_options)
      raise NotImplementedError
    end

    def provider_class
      self.class
    end

    def environment
      if preferred_test_mode
        :test
      else
        :live
      end
    end

    def create_profile(payment); end

    def payment_session_result(payment_session_id, session_result)
      response = send_request do
        client.checkout.payments_api.get_result_of_payment_session(payment_session_id, query_params: { sessionResult: session_result })
      end
      response_body = response.response

      if response.status.to_i == 200
        success(response_body.id, response_body)
      else
        failure(response_body.slice('pspReference', 'message').values.join(' - '))
      end
    end

    # Creates a Adyen payment session for the order
    #
    # @param amount_in_cents [Integer] the amount in cents
    # @param order [Spree::Order] the order to create a payment session for
    # @return [ActiveMerchant::Billing::Response] the response from the payment session creation
    def create_payment_session(amount_in_cents, order)
      payload = SpreeAdyen::PaymentSessions::RequestPayloadPresenter.new(
        order: order,
        amount: amount_in_cents,
        user: order.user,
        merchant_account: preferred_merchant_account,
        payment_method: self
      ).to_h

      response = send_request do
        client.checkout.payments_api.sessions(payload, headers: { 'Idempotency-Key' => SecureRandom.uuid })
      end
      response_body = response.response

      if response.status.to_i == 201
        success(response_body.id, response_body)
      else
        failure(response_body.slice('pspReference', 'message').values.join(' - '))
      end
    end

    # @return [Boolean] whether payment profiles are supported
    # this is used by spree to determine whenever payment source must be passed to gateway methods
    def payment_profiles_supported?
      true
    end

    def default_name
      'Adyen'
    end

    def method_type
      'spree_adyen'
    end

    def payment_icon_name
      'adyen'
    end

    def description_partial_name
      'spree_adyen'
    end

    def configuration_guide_partial_name
      'spree_adyen'
    end

    def reusable_sources(order)
      if order.completed?
        sources_by_order order
      elsif order.user.present?
        credit_cards.where(user_id: order.user_id)
      else
        []
      end
    end

    private

    def client
      @client ||= Adyen::Client.new.tap do |client|
        client.api_key = preferred_api_key
        client.env = Rails.env.production? ? :live : :test
      end
    end

    def send_request
      yield
    rescue Adyen::AdyenError => e
      raise Spree::Core::GatewayError, e.message
    end

    def success(authorization, full_response)
      ActiveMerchant::Billing::Response.new(true, nil, full_response.as_json, authorization: authorization)
    end

    def failure(error = nil)
      ActiveMerchant::Billing::Response.new(false, error)
    end
  end
end
