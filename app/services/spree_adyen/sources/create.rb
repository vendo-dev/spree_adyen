module SpreeAdyen
  class CreateSource
    SOURCE_KLASS_MAP = {
      'klarna' => SpreeAdyen::PaymentSources::Klarna,
      'afterpay_clearpay' => SpreeAdyen::PaymentSources::AfterPay,
      'sepa_debit' => SpreeAdyen::PaymentSources::SepaDebit,
      'p24' => SpreeAdyen::PaymentSources::Przelewy24,
      'ideal' => SpreeAdyen::PaymentSources::Ideal,
      'alipay' => SpreeAdyen::PaymentSources::Alipay,
      'link' => SpreeAdyen::PaymentSources::Link,
      'affirm' => SpreeAdyen::PaymentSources::Affirm
    }.freeze

    def initialize(adyen_payment_method_details:, adyen_payment_method_id:, gateway:, adyen_billing_details:, order: nil, user: nil)
      @adyen_payment_method_details = adyen_payment_method_details
      @adyen_payment_method_id = adyen_payment_method_id
      @gateway = gateway
      @user = user || order&.user
      @adyen_billing_details = adyen_billing_details
      @order = order
    end

    def call
      return find_or_create_credit_card if source_type == 'card'

      source_klass_factory.new(source_params_factory).call
    end

    def find_or_create_credit_card
      SpreeAdyen::Sources::FindOrCreateCreditCard.new(
        adyen_payment_method_details: adyen_payment_method_details,
        adyen_payment_method_id: adyen_payment_method_id,
        card_details: card_details,
        gateway: gateway,
        adyen_billing_details: adyen_billing_details,
        order: order,
        user: user
      ).call
    end

    private

    attr_reader :gateway, :user, :adyen_payment_method_details, :adyen_payment_method_id, :adyen_billing_details, :order

    delegate :type, to: :adyen_payment_method_details, prefix: :source

    def source_klass_factory
      @source_klass_factory ||= SOURCE_KLASS_MAP[source_type] || raise("[ADYEN] Unknown payment method #{source_type}")
    end

    def source_params_factory
      case source_klass_factory
      when SpreeAdyen::PaymentSources::Ideal then source_params.merge(
        bank: adyen_payment_method_details.ideal.bank,
        last4: adyen_payment_method_details.ideal.iban_last4
      )
      when SpreeAdyen::PaymentSources::Przelewy24 then source_params.merge(bank: adyen_payment_method_details.p24.bank)
      else
        source_params
      end
    end

    def source_params
      {
        gateway_payment_profile_id: adyen_payment_method_id,
        payment_method: gateway
      }
    end
  end
end
