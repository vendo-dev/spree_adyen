require 'spec_helper'

RSpec.describe SpreeAdyen::PaymentSessions::Create do
  subject(:service) { described_class.new(order: order, user: user, amount: amount, payment_method: payment_method).call }

  let(:order) { create(:order) }
  let(:user) { create(:user) }
  let(:amount) { 100 }
  let(:payment_method) { create(:adyen_gateway) }

  let(:existing_payment_session) do
    create(:payment_session,
      order: payment_order,
      status: payment_status,
      expires_at: 1.hour.from_now,
      user: payment_user,
      amount: payment_amount,
      payment_method: payment_payment_method
    )
  end

  before do
    # we use expires_at from the cassette, so we need to freeze the time
    Timecop.freeze('2025-07-07T0:00:00+02:00')
  end

  after do
    Timecop.return
  end

  it 'creates a payment session' do
    VCR.use_cassette('payment_sessions/success') do
      expect { service }.to change(SpreeAdyen::PaymentSession, :count).by(1)
    end
  end
end
