require 'spec_helper'

RSpec.describe SpreeAdyen::PaymentSessions::Create do
  let(:order) { create(:order) }
  let(:user) { create(:user) }
  let(:amount) { 100 }

  subject { described_class.new(order: order, user: user, amount: amount) }

  xit 'creates a payment session' do
    expect { subject.call }.to change(SpreeAdyen::PaymentSession, :count).by(1)
  end
end 