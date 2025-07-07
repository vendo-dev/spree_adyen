require 'spec_helper'

RSpec.describe SpreeAdyen::Gateway do
  let(:store) { Spree::Store.default }
  let(:gateway) { create(:adyen_gateway, stores: [store]) }
  let(:amount) { 100 }

  describe 'send_request' do
    subject { gateway.send_request { action } }

    context 'when action raises Adyen::AdyenError error' do
      let(:action) { raise Adyen::AdyenError.new(response: { 'status' => 400, 'pspReference' => '123', 'message' => 'test' }) }

      it 'protects Adyen API errors' do
        expect { subject }.to raise_error(Spree::Core::GatewayError, 'Adyen::AdyenError request:{:response=>{"status"=>400, "pspReference"=>"123", "message"=>"test"}}')
      end
    end

    context 'when action raises other error' do
      let(:action) { raise 'test' }

      it 'raises error' do
        expect { subject }.to raise_error(StandardError, 'test')
      end
    end
  end

  describe 'create_payment_session' do
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
          expect(subject.message).to eq("X8HRG2XMVS3JHPT5 - Field 'countryCode' is not valid.")
        end
      end
    end
  end
end
