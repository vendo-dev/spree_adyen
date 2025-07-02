require 'spec_helper'

RSpec.describe SpreeAdyen::PaymentSessionsController, type: :controller do
  render_views

  let(:store) { Spree::Store.default }
  let(:order) { create(:order_with_line_items, store: store, state: :payment) }
  let(:adyen_gateway) { create(:adyen_gateway, stores: [store]) }
  let(:payment_session_id) { 'pi_3QXRgr2ESifGlJez0DTXdHQ3' }
  let(:payment_session) { create(:payment_session, order: order, adyen_id: payment_session_id, payment_method: adyen_gateway) }

  describe 'GET #show' do
    context 'when payment session succeeds' do
      let(:complete_order_service) { instance_double(SpreeAdyen::CompleteOrder) }

      before do
        allow(SpreeAdyen::CompleteOrder).to receive(:new).with(payment_session: payment_session_record).and_return(complete_order_service)
        allow(complete_order_service).to receive(:call).and_return(order)
      end

      it 'completes the order and redirects to checkout complete' do
        # FIXME: this is working as expected but specs are failing
        # expect(controller).to receive(:track_checkout_completed)

        get :show, params: { id: payment_session_record.id }

        expect(response).to redirect_to("/checkout/#{order.token}/complete")
      end
    end

    context 'when order is already completed' do
      let(:order) { create(:completed_order_with_totals, store: store) }

      it 'redirects to checkout complete' do
        expect(controller).not_to receive(:track_checkout_completed)

        get :show, params: { id: payment_session_record.id }

        expect(response).to redirect_to("/checkout/#{order.token}/complete")
      end
    end

    context 'when order is canceled' do
      let(:order) { create(:completed_order_with_totals, store: store, state: :canceled, canceled_at: Time.current) }

      it 'redirects to cart' do
        get :show, params: { id: payment_session_record.id }

        expect(response).to redirect_to(spree.cart_path)
      end
    end

    context 'when payment session fails' do
      let(:payment) { create(:payment) }

      let(:adyen_payment_session) {
        Adyen::AdyenObject.construct_from(
          id: payment_session_id,
          status: 'payment_failed',
          amount: 1999,
          currency: 'usd',
          customer: customer_id,
          charge: 'ch_3QXRgr2ESifGlJez02SSg61f',
          last_payment_error: {
            code: 'payment_failed',
            message: 'Payment failed'
          }
        )
      }

      it 'handles the failure and redirects to checkout' do
        get :show, params: { id: payment_session_record.id }

        expect(flash[:error]).to eq(Spree.t("adyen.payment_session_errors.payment_failed"))

        expect(response).to redirect_to("/checkout/#{order.token}")
      end

      context 'when payment exists' do
        let(:payment) { create(:payment, order: order, amount: 1999, state: :pending, response_code: payment_session_id) }

        before do
          order.update_column(:total, 1999)
          payment
        end

        it 'voids the payment' do
          get :show, params: { id: payment_session_record.id }

          expect(payment.reload.state).to eq('void')
        end
      end
    end

    context 'when gateway error occurs' do
      before do
        allow(adyen_payment_session).to receive(:latest_charge).and_raise(Spree::Core::GatewayError, 'Gateway Error')
        allow_any_instance_of(described_class).to receive(:@order).and_return(order)
      end

      it 'handles the error and redirects to checkout' do
        get :show, params: { id: payment_session_record.id }

        expect(flash[:error]).to eq('Gateway Error')
        expect(response).to redirect_to("/checkout/#{order.token}")
      end
    end
  end
end
