require 'spec_helper'

RSpec.describe SpreeAdyen::PaymentSessions::RequestPayloadPresenter do
  subject(:serializer) { described_class.new(order: order, amount: amount, user: user, merchant_account: merchant_account) }

  let(:order) { create(:order, bill_address: bill_address, number: 'R123456789', user: user, currency: 'USD', line_items: [line_item]) }
  let(:user) { create(:user, email: 'test@example.com', first_name: 'John', last_name: 'Doe') }
  let(:amount) { 100 }
  let(:merchant_account) { 'SpreeCommerceECOM' }
  let(:line_items) { [line_item] }
  let(:line_item) { build(:line_item, price: 100, variant: variant) }
  let(:variant) { create(:variant, sku: 'variant_sku', name: 'variant_name') }
  let(:bill_address) { create(:address, firstname: 'John', lastname: 'Doe') }

  context 'with valid params' do
    let(:expected_payload) do
      {
        amount: {
          value: amount,
          currency: order.currency
        },
        returnUrl: "https://#{Rails.application.routes.default_url_options[:host]}/adyen/payment_sessions",
        reference: 'R123456789',
        countryCode: bill_address.country_iso,
        lineItems: [
          {
            id: line_item.id,
            sku: line_item.sku,
            quantity: line_item.quantity,
            description: line_item.name,
            amountExcludingTax: 10000,
            amountIncludingTax: 10000
          }
        ],
        merchantAccount: merchant_account,
        merchantOrderReference: 'R123456789',
        expiresAt: 60.minutes.from_now.iso8601,
        additionalData: { spree_order_id: order.id },
        channel: 'Web',
        shopperName: {
          firstName: 'John',
          lastName: 'Doe'
        },
        shopperEmail: order.email,
        shopperReference: format('%03d', user.id)
      }
    end

    describe '#to_h' do
      subject(:payload) { serializer.to_h }

      it 'returns a valid payload' do
        expect(payload).to eq(expected_payload)
      end
    end
  end
end