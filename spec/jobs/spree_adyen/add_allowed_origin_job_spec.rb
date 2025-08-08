require 'spec_helper'

RSpec.describe SpreeAdyen::AddAllowedOriginJob do
  subject { described_class.new.perform(url, gateway.id) }

  let(:gateway) { create(:adyen_gateway, id: 1, preferred_api_key: 'AQEvhmfxK4vIbBRGw0m/n3Q5qf3Ve5tfCJZpV2hbw2qom++FEca+71BKDHj55mWPzdAQwV1bDb7kfNy1WIxIIkxgBw==-nGKyaWaKpW3QXj0AyKqmEkEoL4igjamBa0klnyYva0U=-i1iW8&%Jsdx*$&pn(gu') }
  let(:url) { 'example.com' }

  before do
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:warn)
    allow(Rails.error).to receive(:unexpected)
  end

  it 'calls adyen API' do
    VCR.use_cassette('jobs/spree_adyen/add_allowed_origin_job/success') do
      expect(Rails.logger).to receive(:info).with("[SpreeAdyen][AddAllowedOriginJob]: Origin https://example.com added to gateway #{gateway.id}")

      subject
    end
  end

  context 'when the allowed origin already exists' do
    it 'does not raise an error and logs a warning' do
      VCR.use_cassette('jobs/spree_adyen/add_allowed_origin_job/already_exists') do
        expect(Rails.logger).to receive(:warn).with('[SpreeAdyen][AddAllowedOriginJob]: Origin https://example.com already exists')
        
        subject
      end
    end
  end

  context 'when the allowed origin cannot be created' do
    it 'raises Rails.error.unexpected with the correct context' do
      VCR.use_cassette('jobs/spree_adyen/add_allowed_origin_job/failed') do
        expect(Rails.error).to receive(:unexpected).with('Cannot create allowed origin', context: { url: 'https://example.com', gateway_id: gateway.id }, source: 'spree_adyen')

        subject
      end
    end
  end
end
