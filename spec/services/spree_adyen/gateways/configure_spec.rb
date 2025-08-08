require 'spec_helper'

RSpec.describe SpreeAdyen::Gateways::Configure do
  subject(:service) { described_class.new(gateway).call }

  let(:gateway) { build(:adyen_gateway, stores: [store], preferred_hmac_key: hmac_key, preferred_webhook_id: webhook_id, preferred_api_key: 'AQEvhmfxK4vIbBRGw0m/n3Q5qf3Ve5tfCJZpV2hbw2qom++FEca+71BKDHj55mWPzdAQwV1bDb7kfNy1WIxIIkxgBw==-nGKyaWaKpW3QXj0AyKqmEkEoL4igjamBa0klnyYva0U=-i1iW8&%Jsdx*$&pn(gu') }
  let(:store) { create(:store, url: 'store.example.com') }

  before do
    create(:custom_domain, store: store, url: 'foo.store.example.com')
    create(:custom_domain, store: store, url: 'bar.store.example.com')
  end

  context 'when the webhook is not valid (invalid hmac or webhook id)' do
    let(:hmac_key) { 'DUADUAUDUADUAUDAU' }
    let(:webhook_id) { 'DUADUAUDUADUAUDAUBLEBLEBLEBLE' }

    it 'updates the webhook_id and hmac_key' do
      VCR.use_cassette('gateways/configure/success/webhook_not_valid') do
        expect { service }.to change(gateway, :preferred_webhook_id)
                         .and change(gateway, :preferred_hmac_key)
      end
    end
  end

  context 'when the webhook is not set up' do
    let(:webhook_id) { nil }
    let(:hmac_key) { nil }

    it 'does a thing' do
      VCR.use_cassette('gateways/configure/success/webhook_not_set_up') do
        service
      end
    end
  end

  context 'when webhook is set up' do
    let(:hmac_key) { '803CB6B178ECEBD56C378B546AC75FEB786FA39352A51B370711377BCE763F63' }
    let(:webhook_id) { 'WBHK42CLX22322945MWKG7R6LH6G9V' }

    it 'does a thing' do
      VCR.use_cassette('gateways/configure/success/webhook_set_up') do
        service
      end
    end
  end
end
