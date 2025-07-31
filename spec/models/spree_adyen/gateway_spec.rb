require 'spec_helper'

RSpec.describe SpreeAdyen::Gateway do
  let(:store) { Spree::Store.default }
  let(:gateway) { create(:adyen_gateway, stores: [store]) }
  let(:amount) { 100 }

  describe '#payment_session_result' do
    subject { gateway.payment_session_result(payment_session_id, session_result) }

    let(:payment_session_id) { 'CS4FBB6F827EC53AC7' }
    let(:session_result) { 'resultData' }

    context 'with valid params' do
      it 'returns proper (successful) ActiveMerchant::Billing::Response instance' do
        VCR.use_cassette('payment_session_results/success/completed') do
          expect(subject).to be_a(ActiveMerchant::Billing::Response)
          expect(subject.success?).to be_truthy
          expect(subject.authorization).to eq(payment_session_id)
        end
      end
    end

    context 'with invalid params' do
      let(:session_result) { 'invalid' }

      it 'returns proper (unsuccessful) ActiveMerchant::Billing::Response instance' do
        VCR.use_cassette('payment_session_results/failure') do
          expect(subject).to be_a(ActiveMerchant::Billing::Response)
          expect(subject.success?).to be_falsey
          expect(subject.message).to eq('F7CHQBP9MCWNRQT5 - server could not process request')
        end
      end
    end
  end

  describe '#create_payment_session' do
    subject { gateway.create_payment_session(amount, order) }

    let(:order) { create(:order_with_line_items) }
    let(:bill_address) { order.bill_address }

    let(:payment_session_id) { 'CS6B11058E72127704' }

    context 'with valid params' do
      it 'returns proper (successful) ActiveMerchant::Billing::Response instance' do
        VCR.use_cassette('payment_sessions/success') do
          expect(subject).to be_a(ActiveMerchant::Billing::Response)
          expect(subject.success?).to be_truthy
          expect(subject.authorization).to eq(payment_session_id)
        end
      end
    end

    context 'with invalid params' do
      before do
        allow(bill_address).to receive(:country_iso).and_return('INVALID')
      end

      it 'returns proper (unsuccessful) ActiveMerchant::Billing::Response instance' do
        VCR.use_cassette('payment_sessions/failure') do
          expect(subject).to be_a(ActiveMerchant::Billing::Response)
          expect(subject.success?).to be_falsey
          expect(subject.message).to eq("N3FFD9KVFQ85K5V5 - Field 'countryCode' is not valid.")
        end
      end
    end
  end

  describe '#environment' do
    subject { gateway.environment }

    context 'when test_mode is true' do
      it { is_expected.to eq(:test) }
    end

    context 'when test_mode is false' do
      let(:gateway) { create(:adyen_gateway, preferred_test_mode: false) }

      it { is_expected.to eq(:live) }
    end
  end
end
