require 'spec_helper'

RSpec.describe SpreeAdyen::Webhooks::Actions::CreateSource do
  subject(:service) { described_class.new(event: event).call }

  let(:event) { SpreeAdyen::Webhooks::Event.new(event_data: event_data) }


  let(:session) { create(:payment_session, adyen_id: 'CS4FBB6F827EC53AC7', status: 'pending') }

  context 'with credit card payment method' do
    let(:event_data) do
      {
        "live": "false",
        "notificationItems": [
          {
            "NotificationRequestItem": {
              "additionalData": {
                "expiryDate": "03/2030",
                "authCode": '12345',
                "cardSummary": "0004",
                "isCardCommercial": "something",
                "threeds2.cardEnrolled": "false",
                "checkoutSessionId": session.adyen_id,
                "paymentMethod": "mc",
                "checkout.cardAddedBrand": "**",
                "storedPaymentMethodId": "HF7Z59JSZZSBJWT5",
                "hmacSignature": "m1dnv+xFOwkdlMhiACVsms6Z/wmal0tuodl4qzD0BTs="
              },
              "amount": {
                "currency": "EUR",
                "value": 1000
              },
              "eventCode": "AUTHORISATION",
              "eventDate": "2025-07-04T12:59:19+02:00",
              "merchantAccountCode": "SpreeCommerceECOM",
              "merchantReference": "d236555b-14d8-48cc-b53c-6a8788c2bb1e",
              "operations": [
                "CANCEL",
                "CAPTURE",
                "REFUND"
              ],
              "paymentMethod": "mc",
              "pspReference": "123432123",
              "reason": "087969:0004:03/2030",
              "success": "true"
            }
          }
        ]
      }
    end

    it 'creates a credit card' do
      expect { service }.to change(Spree::CreditCard, :count).by(1)
    end

    it 'creates a credit card with the correct attributes' do
      expect { service }.to change(Spree::CreditCard, :count).by(1)
      expect(Spree::CreditCard.last.gateway_payment_profile_id).to eq('HF7Z59JSZZSBJWT5')
      expect(Spree::CreditCard.last.month).to eq(3)
      expect(Spree::CreditCard.last.year).to eq(2030)
    end
  end

  context 'when the payment method is not a credit card' do
    let(:event_data) do
      {
        "live": "false",
        "notificationItems": [
          {
            "NotificationRequestItem": {
              "additionalData": {
                'checkoutSessionId': session.adyen_id
              },
              "amount": {
                "currency": "EUR",
                "value": 1000
              },
              "eventCode": "AUTHORISATION",
              "eventDate": "2025-07-04T12:59:19+02:00",
              "merchantAccountCode": "SpreeCommerceECOM",
              "merchantReference": "d236555b-14d8-48cc-b53c-6a8788c2bb1e",
              "operations": [
                "CANCEL",
                "CAPTURE",
                "REFUND"
              ],
              "paymentMethod": "klarna",
              "pspReference": "123432123",
              "reason": "null",
              "success": "true"
            }
          }
        ]
      }
    end

    it 'creates a custom payment source' do
      expect { service }.to change(SpreeAdyen::PaymentSources::Klarna, :count).by(1)
    end
  end
end
