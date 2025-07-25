# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpreeAdyen::WebhooksController, type: :controller do
  render_views

  let(:user_encoded_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials('login', 'password') }
  let(:valid_hmac) { true }

  let(:payment_method) { create(:adyen_gateway) }

  describe 'POST #create' do
    xdescribe 'endpoint auth' do
      before do
        # testing only auth in this block
        allow_any_instance_of(SpreeAdyen::Webhooks::HandleEvent).to_receive(:call).and_return(true)
      end

      context 'with valid hmac' do
        let(:valid_hmac) { true }

        it 'returns a 200 status code' do
          post :create, params: { webhook: params }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'with invalid hmac' do
        let(:valid_hmac) { false }

        it 'returns a 401 status code' do
          post :create, params: { webhook: params }

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    describe 'full webhook flow' do
      subject { post :create, body: params.to_json }

      describe 'authorisation event' do
        let(:order) { create(:order_with_line_items, state: 'payment') }
        let!(:payment) { create(:payment, skip_source_requirement: true, payment_method: payment_method, source: nil, order: order, amount: order.total_minus_store_credits, response_code: 'webhooks_authorisation_success_checkout_session_id') }
        let!(:payment_session) { create(:payment_session, amount: order.total_minus_store_credits, currency: order.currency, payment_method: payment_method, order: order, adyen_id: 'webhooks_authorisation_success_checkout_session_id') }

        context 'with valid payment' do
          context 'with other payment (blik)' do
            let(:params) { JSON.parse(file_fixture('webhooks/authorised/success.json').read) }

            it 'completes the order' do
              expect { subject }.to change { order.reload.completed? }.from(false).to(true)

              expect(response).to have_http_status(:ok)
            end

            it 'completes the payment' do
              expect { subject }.to change { payment.reload.state }.from('checkout').to('completed')

              expect(response).to have_http_status(:ok)
            end

            it 'creates a blik payment source' do
              subject
              
              expect(payment.reload.source).to be_a(SpreeAdyen::PaymentSources::Blik)
              expect(response).to have_http_status(:ok)
            end
          end

          context 'with card details' do
            let(:params) { JSON.parse(file_fixture('webhooks/authorised/success_with_cc_details.json').read) }

            it 'completes the order' do
              expect { subject }.to change { order.reload.completed? }.from(false).to(true)

              expect(response).to have_http_status(:ok)
            end

            it 'completes the payment' do
              expect { subject }.to change { payment.reload.state }.from('checkout').to('completed')

              expect(response).to have_http_status(:ok)
            end

            it 'creates a credit card with card details' do
              subject
              
              cc = payment.reload.source
              expect(cc).to be_a(Spree::CreditCard)
              expect(cc.gateway_payment_profile_id).to eq('webhooks_authorisation_success_stored_payment_method_id')
              expect(cc.last_digits).to eq('7777')
              expect(cc.year).to eq(2077)
              expect(cc.month).to eq(12)
              expect(cc.cc_type).to eq('master')

              expect(response).to have_http_status(:ok)
            end
          end
        end

        xcontext 'with failed payment' do
        end
      end
    end
  end
end
