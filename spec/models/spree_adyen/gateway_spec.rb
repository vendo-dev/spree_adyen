require 'spec_helper'

RSpec.describe SpreeAdyen::Gateway do
  subject(:gateway) do
    create(:adyen_gateway,
      preferred_api_key: 'secret',
      preferred_merchant_account: 'SpreeCommerceECOM',
      preferred_test_mode: test_mode)
  end

  let(:test_mode) { true }

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

  describe '#gateway_dashboard_payment_url' do
    subject { gateway.gateway_dashboard_payment_url(payment) }
    
    let(:payment) { create(:payment, transaction_id: transaction_id) }

    context 'when payment has a transaction_id' do
      let(:transaction_id) { '1234567890' }

      context 'when test_mode is true' do
        let(:test_mode) { true }

        it 'returns the correct URL' do
          expect(subject).to eq('https://ca-test.adyen.com/ca/ca/accounts/showTx.shtml?pspReference=1234567890&txType=Payment')
        end
      end

      context 'when test_mode is false' do
        let(:test_mode) { false }

        it 'returns the correct URL' do
          expect(subject).to eq('https://ca-live.adyen.com/ca/ca/accounts/showTx.shtml?pspReference=1234567890&txType=Payment')
        end
      end
    end

    context 'when payment has no transaction_id' do
      let(:payment) { create(:payment, transaction_id: nil) }
      
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#create_payment_session' do
    subject { gateway.create_payment_session(amount, order, channel) }

    let(:order) { create(:order_with_line_items) }
    let(:bill_address) { order.bill_address }
    let(:amount) { 100 }
    let(:channel) { 'Web' }

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

  describe '#cancel' do
    subject { gateway.cancel(payment.response_code, payment) }

    let!(:refund_reason) { Spree::RefundReason.first || create(:default_refund_reason) }

    context 'when payment is completed' do
      let(:order) { create(:order, total: 10, number: 'R142767632') }
      let(:payment) { create(:payment, state: 'completed', order: order, payment_method: gateway, amount: 10.0, response_code: 'X4G6K4DDZ46B8ZV5') }

      it 'creates a refund with credit_allowed_amount' do
        VCR.use_cassette("payment_api/create_refund/success") do
          expect { subject }.to change(Spree::Refund, :count).by(1)

          expect(payment.refunds.last.amount).to eq(10.0)
          expect(subject.success?).to be(true)
          expect(subject.authorization).to eq(payment.response_code)
        end
      end

      context 'if amount to refund is zero' do
        let!(:refund) { create(:refund, payment: payment, amount: payment.amount) }

        it 'does not create refund' do
          expect { subject }.not_to change(Spree::Refund, :count)

          expect(subject.success?).to be true
        end
      end
    end

    context 'when payment is not completed' do
      let(:payment) { create(:payment, state: 'processing') }

      it 'voids the payment' do
        expect { subject }.not_to change(Spree::Refund, :count)

        expect(payment.reload.state).to eq('void')
        expect(subject.authorization).to eq(payment.response_code)
      end
    end

    context 'when response is not successful' do
      let(:payment) { create(:payment, state: 'completed', order: order, payment_method: gateway, amount: 10.0, response_code: 'foobar') }
      let(:order) { create(:order, total: 10, number: 'R142767632') }

      it 'should raises Spree::Core::GatewayError with the error message' do
        VCR.use_cassette("payment_api/create_refund/failure/invalid_payment_id") do
          expect { subject }.to raise_error(Spree::Core::GatewayError, 'X4NZMCHN86JCNP65 - Original pspReference required for this operation')
        end
      end
    end
  end

  describe '#credit' do
    subject { gateway.credit(amount_in_cents, payment.source, passed_response_code, {}) }

    let(:order) { create(:order, total: 10, number: 'R142767632') }
    let(:payment) { create(:payment, state: 'completed', order: order, payment_method: gateway, amount: 10.0, response_code: 'X4G6K4DDZ46B8ZV5') }
    let(:amount_in_cents) { 800 }
    let(:passed_response_code) { payment.response_code }

    it 'refunds some of the payment amount' do
      VCR.use_cassette("payment_api/create_refund/success_partial") do
        expect(subject.success?).to be(true)
        expect(subject.params['response']['amount']['value']).to eq(amount_in_cents)
      end 
    end

    context 'when response is not successful' do
      let(:payment) { create(:payment, state: 'completed', order: order, payment_method: gateway, amount: 10.0, response_code: 'X4G6K4DDZ46B8ZV5') }
      let(:order) { create(:order, total: 10, number: 'R142767632') }
      let(:amount_in_cents) { 0 }

      it 'should return failure response' do
        VCR.use_cassette("payment_api/create_refund/failure/invalid_amount") do
          expect(subject.success?).to eq(false)
          expect(subject.message).to eq("SQLBC925DFMK8B75 - Field 'amount' is not valid.")
        end
      end
    end

    context 'when payment is not found' do
      let(:passed_response_code) { 'foobar' }

      it 'should return failure response' do
        expect(subject.success?).to eq(false)
        expect(subject.message).to eq("foobar - Payment not found")
      end
    end
  end
end
