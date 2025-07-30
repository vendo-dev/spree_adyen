require 'spec_helper'

RSpec.describe SpreeAdyen::PaymentSessions::ProcessWithResult do
  subject(:service) { described_class.new(payment_session: payment_session, session_result: session_result).call }

  let(:payment_session) { create(:payment_session, adyen_id: 'CS4FBB6F827EC53AC7', status: 'initial') }
  let(:session_result) { 'Ab02b4c0!BQABAgBWDdfk9YmejOwxjS8uGQ3SggavRtpgoKqEBlShyLIYXvBPiXq+sku8Jb8uKSaLv2RYrDNc6V9mfLFIfYnh4Xz4UnOPKTks9+XHaJuYXlwKo6+hg+mVGhMl1eFCkJHlpMpWGBUR7SUFXbIuMlOtUg3BXrfJ/6N0oBLbDbrd/R+8rAIySFixSCiB+j+eNn7k3dShemO636LgXuzhtnr9diKgX2SThk9/K5HZhG/9tySSqFycQpfpcx03KwNxi9/dRnjA6bWXjWaQ9uPzpV8cXyNl2LOQTKAJJ93KS98INIdc8opgXQnliomFqCRTipSWTbTR/VXq1egFvcrNVDMH3oxWY8JiFZVJlmcMywXWKyIgylKhhsdS41UnjXOSoAC97OWzBR5Oq5u3HE7UHm9owy1mDazW5tZVP4igRrocSz/Xvwx53HCGRZoDaB4OdMWVGtRsn1B6SGoXnM9B47FaStQQxbCtyuDAbJK3D5VvNrXHOj7yxKDIZcfuBkNCMhS62DznX8kv3KTHJFhHg6/B+tAQBZiwuBS0OqTNzEBYCUH6dzNOJMJq1lQpAXqO5q9XPk59ImSE6U0u0yaQVz5JC4P1phc5CPOCRSeHKeUovtMVoGgHMSx87kCFjNg1Q4AUbcJOB7/IhIc9sIPyNIaD9RDmPXIvnCHFy64uXpmH0dC99wxzuNRSQZd67NPJHhwASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9TSRm1LB5JNT9WwWXsXYCaJA3Df0kgEU05L57BSNcG9vu06B4yFVMJ19Yp6ziirvUTWGFqtQISNPXt5/ax++mQIml/jvmWcogZqfxHQJWxyCMa6ImP9JZ6NzKdX3MLUDQB3Hqz/azjyZySzlVjCMCffIV8mA8Nn9i1QiQ8EHtjLy8GgP9zRhixuwWSJSJA1YYGrqWFgGoCQCUthXzH4Fuu4diKVHjDBoQwVKX472Fp0xeODI7uyHdTuRjs6K+sarj6RvLfk6Wkm8MJ2LNz2EzxGLe6LuAAQ7Rl4pGAXZdbUmwQI+ljMwEm9js58bmiiIQdXloVa7xibXAKcxIpC7FCz3lh+lpntjxqx6no1K5YDEMHs8rUYTws2FNPmO5MVTls+AEGPFkEGGRFib6YoIr708/n/LkrAAbcQYF0RLi4Sp4pZVHphuUIAqlp3DWatlI9w3HbqZxx/lZ39W5hFzLMu4YTA4LB0uhAEsqOKpb0CYbeD6jtZVv/iCW9U9g+PnqSmY3xOjKhGS59dnuVhWU1v5XckZDS1ltKCQi0867tjeADFj1B92lD3zvn/2v1KQdrilWdpK1OzCl6v7Cy12VpvrH7Zw3Dw3/EKP21QOadmX9Du+4xoGyQyYQuVlaRbg=' }

  context 'when payment is completed' do
    it 'updates the payment session status' do
      VCR.use_cassette('payment_session_results/success/completed') do
        expect { service }.to change { payment_session.reload.status }.to('completed')
      end
    end

    it 'creates a payment with completed status' do
      VCR.use_cassette('payment_session_results/success/completed') do
        expect { service }.to change(Spree::Payment, :count).by(1)

        expect(payment_session.order.payments).to be_present
        expect(payment_session.order.payments.last.state).to eq('completed')
      end
    end
  end

  context 'when payment is refused' do
    it 'updates the payment session status' do
      VCR.use_cassette('payment_session_results/success/refused') do
        expect { service }.to change { payment_session.reload.status }.to('refused')
      end
    end

    it 'creates a payment with refused status' do
      VCR.use_cassette('payment_session_results/success/refused') do
        expect { service }.to change(Spree::Payment, :count).by(1)

        expect(payment_session.order.payments).to be_present
        expect(payment_session.order.payments.last.state).to eq('failed')
      end
    end
  end

  context 'when payment is canceled' do
    it 'updates the payment session status' do
      VCR.use_cassette('payment_session_results/success/canceled') do
        expect { service }.to change(payment_session.reload, :status).to('canceled')
      end
    end

    it 'creates a payment with refused status' do
      VCR.use_cassette('payment_session_results/success/canceled') do
        expect { service }.to change(Spree::Payment, :count).by(1)

        expect(payment_session.order.payments).to be_present
        expect(payment_session.order.payments.last.state).to eq('void')
      end
    end
  end

  context 'when payment is still pending (async payment)' do
    it 'updates the payment session status' do
      VCR.use_cassette('payment_session_results/success/payment_pending') do
        expect { service }.to change(payment_session.reload, :status).to('pending')
      end
    end

    it 'creates a payment with processing status' do
      VCR.use_cassette('payment_session_results/success/payment_pending') do
        expect { service }.to change(Spree::Payment, :count).by(1)

        expect(payment_session.order.payments).to be_present
        expect(payment_session.order.payments.last.state).to eq('processing')
      end
    end
  end

  context 'when payment is expired' do
    it 'updates the payment session status' do
      VCR.use_cassette('payment_session_results/success/expired') do
        expect { service }.to change(payment_session.reload, :status).to('refused')
      end
    end

    it 'creates a payment with failed status' do
      VCR.use_cassette('payment_session_results/success/expired') do
        expect { service }.to change(Spree::Payment, :count).by(1)

        expect(payment_session.order.payments).to be_present
        expect(payment_session.order.payments.last.state).to eq('failed')
      end
    end
  end
end