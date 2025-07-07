module SpreeAdyen
  class Gateway < ::Spree::Gateway
    # preference :publishable_key, :password
    # preference :secret_key, :password
    preference :api_key, :password
    preference :merchant_account, :string

    # has_one_attached :apple_developer_merchantid_domain_association, service: Spree.private_storage_service_name

    has_many :payment_sessions, class_name: 'SpreeAdyen::PaymentIntent', foreign_key: 'payment_method_id', dependent: :delete_all

    def self.webhook_url
      "https://#{Rails.application.routes.default_url_options[:host]}/adyen"
    end

    # @param amount_in_cents [Integer] the amount in cents to capture
    # @param payment_source [Spree::CreditCard | Spree::PaymentSource]
    # @param gateway_options [Hash] this is an instance of Spree::Payment::GatewayOptions.to_hash
    def authorize(amount_in_cents, payment_source, gateway_options = {})
      handle_authorize_or_purchase(amount_in_cents, payment_source, gateway_options)
    end

    # @param amount_in_cents [Integer] the amount in cents to capture
    # @param payment_source [Spree::CreditCard | Spree::PaymentSource]
    # @param gateway_options [Hash] this is an instance of Spree::Payment::GatewayOptions.to_hash
    def purchase(amount_in_cents, payment_source, gateway_options = {})
      handle_authorize_or_purchase(amount_in_cents, payment_source, gateway_options)
    end

    # the behavior for authorize and purchase is the same, so we can use the same method to handle both
    def handle_authorize_or_purchase(amount_in_cents, payment_source, gateway_options)
      order_number, payment_number = gateway_options[:order_id].split('-')

      return failure('Order number is invalid') if order_number.blank?
      return failure('Payment number is invalid') if payment_number.blank?

      order = Spree::Order.where(store_id: stores.ids).find_by(number: order_number)
      payment = order.payments.find_by(number: payment_number)

      protect_from_error do
        # eg. payment created via admin
        payment = ensure_payment_session_exists_for_payment(payment, amount_in_cents, payment_source)
        adyen_payment_session = retrieve_payment_session(payment.response_code)

        response = if adyen_payment_session.status == 'succeeded'
                     # payment session is already confirmed via Adyen JS SDK
                     adyen_payment_session
                   else
                     confirm_payment_session(adyen_payment_session.id)
                   end

        success(response.id, response)
      end
    end

    def payment_session_result(payment_session_id, session_result)
      response = send_request do
        client.checkout.payments_api.get_result_of_payment_session(payment_session_id, query_params: { sessionResult: session_result })
      end
      response_body = response.response

      if response.status == 200
        success(response_body.id, response_body)
      else
        failure(response_body.slice('pspReference', 'message').values.join(' - '))
      end
    end

    def credit(amount_in_cents, _source, payment_session_id, _gateway_options = {})
      raise NotImplementedError
    end

    def capture(amount_in_cents, payment_session_id, _gateway_options = {})
      raise NotImplementedError
    end

    def void(response_code, source, gateway_options)
      raise NotImplementedError
    end

    def cancel(payment_session_id, payment = nil)
      raise NotImplementedError
    end

    # Creates a Adyen payment session for the order
    #
    # @param amount_in_cents [Integer] the amount in cents
    # @param order [Spree::Order] the order to create a payment session for
    # @return [ActiveMerchant::Billing::Response] the response from the payment session creation
    def create_payment_session(amount_in_cents, order)
      payload = SpreeAdyen::PaymentSessions::RequestPayloadSerializer.new(
        order: order,
        amount: amount_in_cents,
        user: order.user,
        merchant_account: preferred_merchant_account
      ).to_h

      response = send_request do
        client.checkout.payments_api.sessions(payload, headers: { 'Idempotency-Key' => SecureRandom.uuid })
      end
      response_body = response.response

      if response.status == 201
        success(response_body.id, response_body)
      else
        failure(response_body.slice('pspReference', 'message').values.join(' - '))
      end
    end

    # Ensures a Adyen payment session exists for Spree payment
    #
    # @param payment [Spree::Payment] the payment to ensure a payment session exists for
    # @param amount_in_cents [Integer] the amount in cents
    # @param payment_source [Spree::CreditCard | Spree::PaymentSource] the payment source to use
    # @return [Spree::Payment] the payment with the payment session

    def ensure_payment_session_exists_for_payment(payment, amount_in_cents = nil, payment_source = nil)
      payment.tap do |payment|
        next if payment.response_code.present?

        amount_in_cents ||= payment.display_amount.cents
        payment_source ||= payment.source

        response = create_payment_session(amount_in_cents, payment.order)

        payment.update_columns(
          response_code: response.authorization,
          updated_at: Time.current
        )
      end
    end

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

    def custom_form_fields_partial_name
      'spree_adyen'
    end

    def configuration_guide_partial_name
      'spree_adyen'
    end

    def client
      @client ||= Adyen::Client.new.tap do |client|
        client.api_key = preferred_api_key
        client.env = Rails.env.production? ? :live : :test
      end
    end

    def send_request
      protect_from_error do
        yield
      end
    end

    private

    def success(authorization, full_response)
      ActiveMerchant::Billing::Response.new(true, nil, full_response.as_json, authorization: authorization)
    end

    def failure(error = nil)
      ActiveMerchant::Billing::Response.new(false, error)
    end

    def protect_from_error
      yield
    rescue Adyen::AdyenError => e
      raise Spree::Core::GatewayError, e.message
    end
  end
end
