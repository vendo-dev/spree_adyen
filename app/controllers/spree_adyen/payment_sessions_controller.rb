# this is the endpoint that Adyen JS SDK will redirect customer to after payment
# it will handle the payment session status and process the payment
module SpreeAdyen
  class PaymentSessionsController < Spree::StoreController
    include Spree::CheckoutAnalyticsHelper

    # GET /spree/payment_sessions/:id
    def show
      # fetch the payment session active record
      @payment_session_record = SpreeAdyen::PaymentSession.find(params[:id])
      @order = @payment_session_record.order

      # handle duplicated requests or already prcessed through webhook
      redirect_to spree.checkout_complete_path(@order.token), status: :see_other if @payment_session_record.status.present?

      @payment_session_record = SpreeAdyen::PaymentSessions::Update.new(payment_session: @payment_session_record,
                                                                        session_result: params[:sessionResult]).call

      if @payment_session_record.reload.succeeded?
        @order = SpreeStripe::CompleteOrder.new(payment_intent: @payment_intent_record).call

        # set the session flag to indicate that the order was placed now
        track_checkout_completed if @order.completed?

        redirect_to spree.checkout_complete_path(@order.token), status: :see_other

      elsif @payment_session_record.failed?
        handle_failure(Spree.t("adyen.payment_session_errors.#{@adyen_payment_session.status}"))
      end
    rescue Spree::Core::GatewayError => e
      handle_failure(e.message)
    end

    private

    def handle_failure(error_message)
      flash[:error] = error_message

      Rails.logger.error("Payment failed for order #{@order.id}: #{@adyen_payment_session.status}")

      # remove the payment session record, so after returning to the checkout page, the customer can try again with a new payment session
      @payment_session_record.destroy!

      # this should be a rare race condition, but we need to handle it
      payment = @order.payments.valid.find_by(response_code: @adyen_payment_session.id)
      payment.void! if payment.present?

      redirect_to spree.checkout_path(@order.token), status: :see_other
    end
  end
end
