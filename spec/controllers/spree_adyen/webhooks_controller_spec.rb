# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SpreeAdyen::WebhooksController, type: :controller do
  render_views

  let(:user_encoded_credentials) { ActionController::HttpAuthentication::Basic.encode_credentials('login', 'password') }
  let(:valid_hmac) { true }

  before do
    expect_any_instance_of(Adyen::Utils::HmacValidator).to receive(:valid_webhook_hmac?).and_return(valid_hmac)

    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('ADYEN_WEBHOOK_USERNAME').and_return('login')
    allow(ENV).to receive(:[]).with('ADYEN_WEBHOOK_PASSWORD').and_return('password')
  end

  xdescribe 'POST #create' do
    let(:params) { JSON.parse(file_fixture('webhooks/authorised/success.json').read) }

    describe 'endpoint auth' do
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
      describe 'authorisation event' do
        context 'with valid payment' do
          context 'with minimum required params' do
            let(:params) { JSON.parse(file_fixture('webhooks/authorised/success.json').read) }

            xit 'completes the order' do
            end

            xit 'creates a new payment' do
            end

            xit 'creates a payment source' do
            end
          end

          context 'with billing address details' do
            let(:params) { JSON.parse(file_fixture('webhooks/authorised/success_with_billing_address.json').read) }

            xit 'assigns billing address data to order' do
            end
          end

          context 'with card details' do
            let(:params) { JSON.parse(file_fixture('webhooks/authorised/success_with_cc_details.json').read) }

            xit 'saves card details to payment method' do
            end
          end
        end

        context 'with failed payment' do
          context 'with minimum required params' do
            let(:params) { JSON.parse(file_fixture('webhooks/authorised/failed.json').read) }

            xit 'does not complete the order' do
            end

            # ????
            xit 'idk rn' do
            end
          end
        end
      end
    end
  end
end
