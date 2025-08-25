require 'spec_helper'

RSpec.describe SpreeAdyen::Gateways::AddAllowedOrigin do
  subject { described_class.new(record, gateway).call }

  let(:gateway) { create(:adyen_gateway, id: 1) }
  let(:record) { create(:store, url: 'example.com') }
  let(:created_origin_id) { 'S2-3D2236432D4F5D5F7F68793D456E5C2F68733E282A7353396E322F' }

  before do
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:warn)
    allow(Rails.error).to receive(:unexpected)
  end

  context 'when the allowed origin is not set' do
    it 'saves adyen ID and URL in private metadata' do
      VCR.use_cassette('jobs/spree_adyen/add_allowed_origin_job/success') { subject }

      expect(record.adyen_allowed_origin_id).to eq(created_origin_id)
      expect(record.adyen_allowed_origin_url).to eq('https://example.com')
    end

    it 'logs the allowed origin' do      
      expect(Rails.logger).to receive(:info).with("[SpreeAdyen][AddAllowedOrigin]: Origin https://example.com added to gateway #{gateway.id}")

      VCR.use_cassette('jobs/spree_adyen/add_allowed_origin_job/success') { subject }
    end
  end

  context 'when API returns already exists error' do
    it 'logs a warning' do
      expect(Rails.logger).to receive(:warn).with('[SpreeAdyen][AddAllowedOrigin]: Origin https://example.com already exists')

      VCR.use_cassette('jobs/spree_adyen/add_allowed_origin_job/already_exists') { subject }
    end
  end

  context 'when API returns other error (for example: 500)' do
    it 'raises Rails.error.unexpected with the correct context' do
      expect(Rails.error).to receive(:unexpected).with('Cannot create allowed origin', context: { url: 'https://example.com', gateway_id: gateway.id }, source: 'spree_adyen')
      
      VCR.use_cassette('jobs/spree_adyen/add_allowed_origin_job/failed') { subject }
    end
  end
end
