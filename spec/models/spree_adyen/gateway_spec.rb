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

  describe 'payment_session_result' do
    subject { gateway.payment_session_result(payment_session_id, session_result) }

    let(:payment_session_id) { 'CS4FBB6F827EC53AC7' }
    let(:session_result) { 'Ab02b4c0!BQABAgBWDdfk9YmejOwxjS8uGQ3SggavRtpgoKqEBlShyLIYXvBPiXq+sku8Jb8uKSaLv2RYrDNc6V9mfLFIfYnh4Xz4UnOPKTks9+XHaJuYXlwKo6+hg+mVGhMl1eFCkJHlpMpWGBUR7SUFXbIuMlOtUg3BXrfJ/6N0oBLbDbrd/R+8rAIySFixSCiB+j+eNn7k3dShemO636LgXuzhtnr9diKgX2SThk9/K5HZhG/9tySSqFycQpfpcx03KwNxi9/dRnjA6bWXjWaQ9uPzpV8cXyNl2LOQTKAJJ93KS98INIdc8opgXQnliomFqCRTipSWTbTR/VXq1egFvcrNVDMH3oxWY8JiFZVJlmcMywXWKyIgylKhhsdS41UnjXOSoAC97OWzBR5Oq5u3HE7UHm9owy1mDazW5tZVP4igRrocSz/Xvwx53HCGRZoDaB4OdMWVGtRsn1B6SGoXnM9B47FaStQQxbCtyuDAbJK3D5VvNrXHOj7yxKDIZcfuBkNCMhS62DznX8kv3KTHJFhHg6/B+tAQBZiwuBS0OqTNzEBYCUH6dzNOJMJq1lQpAXqO5q9XPk59ImSE6U0u0yaQVz5JC4P1phc5CPOCRSeHKeUovtMVoGgHMSx87kCFjNg1Q4AUbcJOB7/IhIc9sIPyNIaD9RDmPXIvnCHFy64uXpmH0dC99wxzuNRSQZd67NPJHhwASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9TSRm1LB5JNT9WwWXsXYCaJA3Df0kgEU05L57BSNcG9vu06B4yFVMJ19Yp6ziirvUTWGFqtQISNPXt5/ax++mQIml/jvmWcogZqfxHQJWxyCMa6ImP9JZ6NzKdX3MLUDQB3Hqz/azjyZySzlVjCMCffIV8mA8Nn9i1QiQ8EHtjLy8GgP9zRhixuwWSJSJA1YYGrqWFgGoCQCUthXzH4Fuu4diKVHjDBoQwVKX472Fp0xeODI7uyHdTuRjs6K+sarj6RvLfk6Wkm8MJ2LNz2EzxGLe6LuAAQ7Rl4pGAXZdbUmwQI+ljMwEm9js58bmiiIQdXloVa7xibXAKcxIpC7FCz3lh+lpntjxqx6no1K5YDEMHs8rUYTws2FNPmO5MVTls+AEGPFkEGGRFib6YoIr708/n/LkrAAbcQYF0RLi4Sp4pZVHphuUIAqlp3DWatlI9w3HbqZxx/lZ39W5hFzLMu4YTA4LB0uhAEsqOKpb0CYbeD6jtZVv/iCW9U9g+PnqSmY3xOjKhGS59dnuVhWU1v5XckZDS1ltKCQi0867tjeADFj1B92lD3zvn/2v1KQdrilWdpK1OzCl6v7Cy12VpvrH7Zw3Dw3/EKP21QOadmX9Du+4xoGyQyYQuVlaRbg=' }

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
          expect(subject.message).to eq("N3FFD9KVFQ85K5V5 - Field 'countryCode' is not valid.")
        end
      end
    end
  end
end
