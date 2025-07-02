require 'spec_helper'

RSpec.describe SpreeAdyen::Gateway do
  let(:store) { Spree::Store.default }
  let(:gateway) { create(:adyen_gateway, stores: [store]) }
  let(:amount) { 100 }

  describe '#create_payment_session' do
    subject { gateway.create_payment_session(amount, order) }

    let(:order) { create(:order_with_line_items) }

    let(:payment_session_id) { 'CSC9E6046E3CF70774' }

    it 'creates payment session' do
      VCR.use_cassette('gateway_create_payment_session/success') do
        expect(subject.success?).to be_truthy
        expect(subject.authorization).to eq(payment_session_id)
      end
    end

    xcontext 'when shipping address is invalid' do
      let(:order) do
        build(
          :order_with_line_items,
          ship_address: build(:address, address1: nil),
          store: Spree::Store.default
        )
      end

      it 'creates the payment session without shipping address' do
        VCR.use_cassette('create_payment_session_invalid_address') do
        end
      end
    end
  end

  describe '#purchase' do
    subject { gateway.purchase(amount_in_cents, credit_card, { order_id: order_id }) }

    let(:amount_in_cents) { 1000 }
    let(:order_id) { "#{order.number}-#{payment.number}" }

    let!(:order) { create(:completed_order_with_totals, number: 'R111098765') }

    let!(:credit_card) { create(:credit_card, gateway_payment_profile_id: payment_method_id, payment_method: gateway) }

    let!(:payment) { create(:payment, number: 'ABC1DEF2', amount: 110, payment_method: gateway, order: order, source: credit_card, response_code: nil) }

    let(:payment_method_id) { 'pm_1QXmPJ2ESifGlJezC2py6ZqS' }
    let(:payment_session_id) { 'pi_3QY1y22ESifGlJez12haN8ah' }

    it 'successfully creates a payment session' do
      VCR.use_cassette('create_payment_session_with_payment_method') do
        expect(subject.success?).to be true

        expect(subject.authorization).to eq(payment_session_id)
        expect(subject.params['status']).to eq('succeeded')
        expect(subject.params['amount']).to eq(amount_in_cents)
        expect(subject.params['payment_method']).to eq(payment_method_id)
        expect(subject.params['customer']).to eq(customer_id)
        expect(subject.params['transfer_group']).to eq(order.number)

        expect(payment.reload.response_code).to eq(payment_session_id)
        expect(payment.state).to eq('checkout')
      end
    end

    context 'when order or payment is missing' do
      let(:order_id) { 'missing' }

      it 'returns failure' do
        expect(subject.success?).to be(false)
        expect(payment.reload.state).to eq 'checkout'
      end
    end
  end
end
