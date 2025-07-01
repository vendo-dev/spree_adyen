require 'spec_helper'

RSpec.describe SpreeAdyen::PaymentApi::Sessions::Create do
  subject(:service) { described_class.new(**params).call }

  let(:params) { { payload: payload } }

  let(:payload) do
    {
      amount: {
        value: 1000,
        currency: 'PLN'
      },
      returnUrl: 'https://example.com',
      reference: '1234567890',
      countryCode: 'PL',
      merchantAccount: 'SpreeCommerceECOM',
      shopperEmail: 'test@example.com',
      shopperReference: '1234567890',
      channel: 'Web'
    }
  end

  context 'with valid parameters' do
    context 'with overriden client' do
      let(:client) { SpreeAdyen::PaymentApi::Client.new.call }
      let(:params) do
        {
          payload: payload,
          client: client
        }
      end

      before do
        allow(client).to receive(:checkout).and_call_original
      end
  
      it 'uses the overriden client' do
        expect(client).to have_received(:checkout).once
  
        VCR.use_cassette("payment_api/sessions/create/succes") { service }
      end
    end

    it 'responds with 201 status code' do
      VCR.use_cassette("payment_api/sessions/create/success") do
        expect(service.status).to eq(201)
      end
    end

    it 'responds with session id in response data' do
      VCR.use_cassette("payment_api/sessions/create/success") do
        expect(service.response.id).to be_present
      end
    end
  end

  context 'with invalid parameters' do
    context 'with invalid payload', vcr: { use_cassette: 'payment_api/sessions/create/invalid_payload' } do
      let(:payload) { { amount: { value: 0, currency: 'PLN' } } }
        
      it 'raises an error' do
        expect { service.call }.to raise_error(SpreeAdyen::PaymentApi::Error)
      end
    end

    context 'with invalid api key', vcr: { use_cassette: 'payment_api/sessions/create/invalid_api_key' } do
      before do
        Settings.stripe_adyen.api_key = 'invalid_key'
      end
      
      it 'raises an error' do
        expect { service.call }.to raise_error(SpreeAdyen::PaymentApi::Error)
      end
    end
  end
end 