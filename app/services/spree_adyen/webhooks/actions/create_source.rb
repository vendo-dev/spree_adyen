module SpreeAdyen
  module Webhooks
    module Actions
      class CreateSource
        CREDIT_CARD_SOURCES = %i[
          accel
          amex
          carnet
          cartebancaire
          cup
          diners
          discover
          eftpos_australia
          elo
          googlepay
          maestro
          maestro_usa
          mc
          visa
        ].freeze

        SOURCE_KLASS_MAP = {
          ach: SpreeAdyen::PaymentSources::AchDirectDebit,
          affirm: SpreeAdyen::PaymentSources::Affirm,
          afterpaytouch: SpreeAdyen::PaymentSources::Afterpay,
          alipay: SpreeAdyen::PaymentSources::Alipay,
          alipay_hk: SpreeAdyen::PaymentSources::AlipayHk,
          alma: SpreeAdyen::PaymentSources::Alma,
          ancv: SpreeAdyen::PaymentSources::Ancv,
          atome: SpreeAdyen::PaymentSources::Atome,
          benefit: SpreeAdyen::PaymentSources::Benefit,
          bacs: SpreeAdyen::PaymentSources::Bacs,
          bcmc: SpreeAdyen::PaymentSources::Bancontact,
          bcmc_mobile: SpreeAdyen::PaymentSources::Bancontact,
          bankTransfer_IBAN: SpreeAdyen::PaymentSources::BankTransfer,
          klarna_b2b: SpreeAdyen::PaymentSources::Billie,
          bizum: SpreeAdyen::PaymentSources::Bizum,
          blik: SpreeAdyen::PaymentSources::Blik,
          boleto: SpreeAdyen::PaymentSources::Boleto,
          cashapp: SpreeAdyen::PaymentSources::Cashapp,
          afterpaytouch_US: SpreeAdyen::PaymentSources::CashAppAfterpay,
          clearpay: SpreeAdyen::PaymentSources::Clearpay,
          doku_alfamart: SpreeAdyen::PaymentSources::Doku,
          doku_indomaret: SpreeAdyen::PaymentSources::Doku,
          dana: SpreeAdyen::PaymentSources::Dana,
          duitnow: SpreeAdyen::PaymentSources::Duitnow,
          eps: SpreeAdyen::PaymentSources::Eps,
          fastlane: SpreeAdyen::PaymentSources::Fastlane,
          molpay_ebanking_fpx_MY: SpreeAdyen::PaymentSources::Fpx,
          gcash: SpreeAdyen::PaymentSources::Gcash,
          givex: SpreeAdyen::PaymentSources::GiftCards,
          genericgiftcard: SpreeAdyen::PaymentSources::GiftCards,
          valuelink: SpreeAdyen::PaymentSources::GiftCards,
          svs: SpreeAdyen::PaymentSources::GiftCards,
          giropay: SpreeAdyen::PaymentSources::Giropay,
          ideal: SpreeAdyen::PaymentSources::Ideal,
          grabpay_MY: SpreeAdyen::PaymentSources::Grabpay,
          grabpay_PH: SpreeAdyen::PaymentSources::Grabpay,
          grabpay_SG: SpreeAdyen::PaymentSources::Grabpay,
          jcb: SpreeAdyen::PaymentSources::Jcb,
          klarna: SpreeAdyen::PaymentSources::Klarna,
          klarna_account: SpreeAdyen::PaymentSources::Klarna,
          klarna_paynow: SpreeAdyen::PaymentSources::Klarna,
          klarna_paylater: SpreeAdyen::PaymentSources::Klarna,
          klarna_payovertime: SpreeAdyen::PaymentSources::Klarna
          # TODO: add rest of sources
        }.freeze

        def initialize(event:)
          @event = event
        end

        def call
          if event.payment_method_reference.in?(CREDIT_CARD_SOURCES)
            find_or_create_credit_card
          else
            find_or_create_source
          end
        end

        def find_or_create_source
          source_klass_factory.find_or_create_by(source_params)
        end

        def find_or_create_credit_card
          cc_attributes = SpreeAdyen::Webhooks::CreditCardPresenter.new(event).to_h
          Spree::CreditCard.find_or_create_by(cc_attributes.slice(:gateway_payment_profile_id, :gateway_customer_profile_id)) do |cc|
            cc.assign_attributes(cc_attributes)
            cc.user = payment_session.user
            cc.payment_method = gateway
          end
        end

        private

        attr_reader :event

        delegate :payment_method_reference, to: :event

        def payment_session
          @payment_session ||= SpreeAdyen::PaymentSession.find_by!(adyen_id: event.session_id)
        end

        def source_klass_factory
          SOURCE_KLASS_MAP[event.payment_method_reference] ||= SpreeAdyen::PaymentSources::Unknown
        end

        def gateway
          @gateway ||= payment_session.payment_method
        end

        def source_params
          {
            payment_method: gateway,
            user: payment_session.user
          }
        end
      end
    end
  end
end
