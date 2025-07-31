require 'spec_helper'

RSpec.describe SpreeAdyen::PaymentSessionsController, type: :controller do
  render_views

  let(:store) { Spree::Store.default }
  let(:order) { create(:order_with_line_items, store: store, state: :payment) }
  let(:adyen_gateway) { create(:adyen_gateway, stores: [store]) }
  let(:payment_session_id) { 'CS4FBB6F827EC53AC7' }
  let(:payment_session) { create(:payment_session, order: order, amount: order.total, adyen_id: payment_session_id, payment_method: adyen_gateway) }

  let(:session_result) { 'Ab02b4c0!BQABAgBWDdfk9YmejOwxjS8uGQ3SggavRtpgoKqEBlShyLIYXvBPiXq+sku8Jb8uKSaLv2RYrDNc6V9mfLFIfYnh4Xz4UnOPKTks9+XHaJuYXlwKo6+hg+mVGhMl1eFCkJHlpMpWGBUR7SUFXbIuMlOtUg3BXrfJ/6N0oBLbDbrd/R+8rAIySFixSCiB+j+eNn7k3dShemO636LgXuzhtnr9diKgX2SThk9/K5HZhG/9tySSqFycQpfpcx03KwNxi9/dRnjA6bWXjWaQ9uPzpV8cXyNl2LOQTKAJJ93KS98INIdc8opgXQnliomFqCRTipSWTbTR/VXq1egFvcrNVDMH3oxWY8JiFZVJlmcMywXWKyIgylKhhsdS41UnjXOSoAC97OWzBR5Oq5u3HE7UHm9owy1mDazW5tZVP4igRrocSz/Xvwx53HCGRZoDaB4OdMWVGtRsn1B6SGoXnM9B47FaStQQxbCtyuDAbJK3D5VvNrXHOj7yxKDIZcfuBkNCMhS62DznX8kv3KTHJFhHg6/B+tAQBZiwuBS0OqTNzEBYCUH6dzNOJMJq1lQpAXqO5q9XPk59ImSE6U0u0yaQVz5JC4P1phc5CPOCRSeHKeUovtMVoGgHMSx87kCFjNg1Q4AUbcJOB7/IhIc9sIPyNIaD9RDmPXIvnCHFy64uXpmH0dC99wxzuNRSQZd67NPJHhwASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9TSRm1LB5JNT9WwWXsXYCaJA3Df0kgEU05L57BSNcG9vu06B4yFVMJ19Yp6ziirvUTWGFqtQISNPXt5/ax++mQIml/jvmWcogZqfxHQJWxyCMa6ImP9JZ6NzKdX3MLUDQB3Hqz/azjyZySzlVjCMCffIV8mA8Nn9i1QiQ8EHtjLy8GgP9zRhixuwWSJSJA1YYGrqWFgGoCQCUthXzH4Fuu4diKVHjDBoQwVKX472Fp0xeODI7uyHdTuRjs6K+sarj6RvLfk6Wkm8MJ2LNz2EzxGLe6LuAAQ7Rl4pGAXZdbUmwQI+ljMwEm9js58bmiiIQdXloVa7xibXAKcxIpC7FCz3lh+lpntjxqx6no1K5YDEMHs8rUYTws2FNPmO5MVTls+AEGPFkEGGRFib6YoIr708/n/LkrAAbcQYF0RLi4Sp4pZVHphuUIAqlp3DWatlI9w3HbqZxx/lZ39W5hFzLMu4YTA4LB0uhAEsqOKpb0CYbeD6jtZVv/iCW9U9g+PnqSmY3xOjKhGS59dnuVhWU1v5XckZDS1ltKCQi0867tjeADFj1B92lD3zvn/2v1KQdrilWdpK1OzCl6v7Cy12VpvrH7Zw3Dw3/EKP21QOadmX9Du+4xoGyQyYQuVlaRbg=' }
  
  describe 'GET #show' do
    context 'when payment session succeeds' do
      let(:complete_order_service) { instance_double(SpreeAdyen::Orders::Complete) }
      
      let(:send_request) do
        VCR.use_cassette('payment_session_results/success/completed') do
          get :show, params: { sessionId: payment_session.adyen_id, sessionResult: session_result }
        end
      end

      it 'completes the order and redirects to checkout complete' do
        expect { send_request }.to change(Spree::Payment, :count).by(1)
          .and change { order.reload.state }.to('complete')

        expect(response).to redirect_to("/checkout/#{order.token}/complete")
      end
    end

    context 'when order is already completed' do
      let(:order) { create(:completed_order_with_totals, store: store) }

      it 'redirects to checkout complete' do
        expect(controller).not_to receive(:track_checkout_completed)

        get :show, params: { sessionId: payment_session.adyen_id, sessionResult: session_result }

        expect(response).to redirect_to("/checkout/#{order.token}/complete")
      end
    end

    context 'when order is canceled' do
      let(:order) { create(:completed_order_with_totals, store: store, state: :canceled, canceled_at: Time.current) }

      it 'redirects to cart' do
        get :show, params: { sessionId: payment_session.adyen_id, sessionResult: session_result }

        expect(response).to redirect_to(spree.cart_path)
      end
    end

    context 'when payment session is canceled' do
      let(:payment_session_id) { 'CS4FBB6F827EC53AC7' }
      let(:session_result) { 'Ab02b4c0!BQABAgBWDdfk9YmejOwxjS8uGQ3SggavRtpgoKqEBlShyLIYXvBPiXq%2Bsku8Jb8uKSaLv2RYrDNc6V9mfLFIfYnh4Xz4UnOPKTks9%2BXHaJuYXlwKo6%2Bhg%2BmVGhMl1eFCkJHlpMpWGBUR7SUFXbIuMlOtUg3BXrfJ/6N0oBLbDbrd/R%2B8rAIySFixSCiB%2Bj%2BeNn7k3dShemO636LgXuzhtnr9diKgX2SThk9/K5HZhG/9tySSqFycQpfpcx03KwNxi9/dRnjA6bWXjWaQ9uPzpV8cXyNl2LOQTKAJJ93KS98INIdc8opgXQnliomFqCRTipSWTbTR/VXq1egFvcrNVDMH3oxWY8JiFZVJlmcMywXWKyIgylKhhsdS41UnjXOSoAC97OWzBR5Oq5u3HE7UHm9owy1mDazW5tZVP4igRrocSz/Xvwx53HCGRZoDaB4OdMWVGtRsn1B6SGoXnM9B47FaStQQxbCtyuDAbJK3D5VvNrXHOj7yxKDIZcfuBkNCMhS62DznX8kv3KTHJFhHg6/B%2BtAQBZiwuBS0OqTNzEBYCUH6dzNOJMJq1lQpAXqO5q9XPk59ImSE6U0u0yaQVz5JC4P1phc5CPOCRSeHKeUovtMVoGgHMSx87kCFjNg1Q4AUbcJOB7/IhIc9sIPyNIaD9RDmPXIvnCHFy64uXpmH0dC99wxzuNRSQZd67NPJHhwASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9TSRm1LB5JNT9WwWXsXYCaJA3Df0kgEU05L57BSNcG9vu06B4yFVMJ19Yp6ziirvUTWGFqtQISNPXt5/ax%2B%2BmQIml/jvmWcogZqfxHQJWxyCMa6ImP9JZ6NzKdX3MLUDQB3Hqz/azjyZySzlVjCMCffIV8mA8Nn9i1QiQ8EHtjLy8GgP9zRhixuwWSJSJA1YYGrqWFgGoCQCUthXzH4Fuu4diKVHjDBoQwVKX472Fp0xeODI7uyHdTuRjs6K%2Bsarj6RvLfk6Wkm8MJ2LNz2EzxGLe6LuAAQ7Rl4pGAXZdbUmwQI%2BljMwEm9js58bmiiIQdXloVa7xibXAKcxIpC7FCz3lh%2Blpntjxqx6no1K5YDEMHs8rUYTws2FNPmO5MVTls%2BAEGPFkEGGRFib6YoIr708/n/LkrAAbcQYF0RLi4Sp4pZVHphuUIAqlp3DWatlI9w3HbqZxx/lZ39W5hFzLMu4YTA4LB0uhAEsqOKpb0CYbeD6jtZVv/iCW9U9g%2BPnqSmY3xOjKhGS59dnuVhWU1v5XckZDS1ltKCQi0867tjeADFj1B92lD3zvn/2v1KQdrilWdpK1OzCl6v7Cy12VpvrH7Zw3Dw3/EKP21QOadmX9Du%2B4xoGyQyYQuVlaRbg=' }

      it 'redirects to checkout' do
        VCR.use_cassette('payment_session_results/success/canceled') do
          get :show, params: { sessionId: payment_session.adyen_id, sessionResult: session_result }
        end
        expect(response).to redirect_to("/checkout/#{order.token}")
      end

      it 'voids the payment' do
        VCR.use_cassette('payment_session_results/success/canceled') do
          get :show, params: { sessionId: payment_session.adyen_id, sessionResult: session_result }
        end
        expect(order.payments.first.state).to eq('void')
      end
    end

    context 'when payment session is refused' do
      let(:payment_session_id) { 'CS4FBB6F827EC53AC7' }
      let(:session_result) { 'Ab02b4c0!BQABAgBWDdfk9YmejOwxjS8uGQ3SggavRtpgoKqEBlShyLIYXvBPiXq%2Bsku8Jb8uKSaLv2RYrDNc6V9mfLFIfYnh4Xz4UnOPKTks9%2BXHaJuYXlwKo6%2Bhg%2BmVGhMl1eFCkJHlpMpWGBUR7SUFXbIuMlOtUg3BXrfJ/6N0oBLbDbrd/R%2B8rAIySFixSCiB%2Bj%2BeNn7k3dShemO636LgXuzhtnr9diKgX2SThk9/K5HZhG/9tySSqFycQpfpcx03KwNxi9/dRnjA6bWXjWaQ9uPzpV8cXyNl2LOQTKAJJ93KS98INIdc8opgXQnliomFqCRTipSWTbTR/VXq1egFvcrNVDMH3oxWY8JiFZVJlmcMywXWKyIgylKhhsdS41UnjXOSoAC97OWzBR5Oq5u3HE7UHm9owy1mDazW5tZVP4igRrocSz/Xvwx53HCGRZoDaB4OdMWVGtRsn1B6SGoXnM9B47FaStQQxbCtyuDAbJK3D5VvNrXHOj7yxKDIZcfuBkNCMhS62DznX8kv3KTHJFhHg6/B%2BtAQBZiwuBS0OqTNzEBYCUH6dzNOJMJq1lQpAXqO5q9XPk59ImSE6U0u0yaQVz5JC4P1phc5CPOCRSeHKeUovtMVoGgHMSx87kCFjNg1Q4AUbcJOB7/IhIc9sIPyNIaD9RDmPXIvnCHFy64uXpmH0dC99wxzuNRSQZd67NPJHhwASnsia2V5IjoiQUYwQUFBMTAzQ0E1MzdFQUVEODdDMjRERDUzOTA5QjgwQTc4QTkyM0UzODIzRDY4REFDQzk0QjlGRjgzMDVEQyJ9TSRm1LB5JNT9WwWXsXYCaJA3Df0kgEU05L57BSNcG9vu06B4yFVMJ19Yp6ziirvUTWGFqtQISNPXt5/ax%2B%2BmQIml/jvmWcogZqfxHQJWxyCMa6ImP9JZ6NzKdX3MLUDQB3Hqz/azjyZySzlVjCMCffIV8mA8Nn9i1QiQ8EHtjLy8GgP9zRhixuwWSJSJA1YYGrqWFgGoCQCUthXzH4Fuu4diKVHjDBoQwVKX472Fp0xeODI7uyHdTuRjs6K%2Bsarj6RvLfk6Wkm8MJ2LNz2EzxGLe6LuAAQ7Rl4pGAXZdbUmwQI%2BljMwEm9js58bmiiIQdXloVa7xibXAKcxIpC7FCz3lh%2Blpntjxqx6no1K5YDEMHs8rUYTws2FNPmO5MVTls%2BAEGPFkEGGRFib6YoIr708/n/LkrAAbcQYF0RLi4Sp4pZVHphuUIAqlp3DWatlI9w3HbqZxx/lZ39W5hFzLMu4YTA4LB0uhAEsqOKpb0CYbeD6jtZVv/iCW9U9g%2BPnqSmY3xOjKhGS59dnuVhWU1v5XckZDS1ltKCQi0867tjeADFj1B92lD3zvn/2v1KQdrilWdpK1OzCl6v7Cy12VpvrH7Zw3Dw3/EKP21QOadmX9Du%2B4xoGyQyYQuVlaRbg=' }

      it 'redirects to checkout' do
        VCR.use_cassette('payment_session_results/success/refused') do
          get :show, params: { sessionId: payment_session.adyen_id, sessionResult: session_result }
        end
        expect(response).to redirect_to("/checkout/#{order.token}")
      end
    end
  end
end
