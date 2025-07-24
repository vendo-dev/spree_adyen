require 'spec_helper'

RSpec.describe SpreeAdyen::OrderDecorator do
  let(:order) { create(:order_with_line_items) }

  let(:initial_session) { create(:payment_session, :initial, order: order, amount: order.total_minus_store_credits, currency: order.currency) }
  let(:pending_session) { create(:payment_session, :pending, order: order, amount: order.total_minus_store_credits, currency: order.currency) }
  let(:completed_session) { create(:payment_session, :completed, order: order, amount: order.total_minus_store_credits, currency: order.currency) }

  let(:initial_session_with_different_amount) { create(:payment_session, :initial, skip_amount_and_currency_validation: true, order: order, amount: order.total_minus_store_credits + 1) }
  let(:initial_session_with_different_currency) { create(:payment_session, :initial, skip_amount_and_currency_validation: true, order: order, currency: 'PLN') }

  describe '#outdate_payment_sessions' do
    subject(:outdate_payment_sessions) { order.outdate_payment_sessions }

    it 'outdates all sessions that are not expired and in initial state' do
      expect { outdate_payment_sessions }.to change { initial_session_with_different_amount.reload.status }.to('outdated')
                                          .and change { initial_session_with_different_currency.reload.status }.to('outdated')
                                          .and not_change { initial_session.reload.status }
                                          .and not_change { pending_session.reload.status }
                                          .and not_change { completed_session.reload.status }
    end
  end
end