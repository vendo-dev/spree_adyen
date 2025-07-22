module Spree
  module Api
    module V2
      module Storefront
        module Adyen
          class PaymentSessionsController < BaseController
            include Spree::Api::V2::Storefront::OrderConcern
            before_action :ensure_order
            before_action :require_spree_current_user

            # POST /api/v2/storefront/adyen/payment_sessions
            def create
              spree_authorize! :update, spree_current_order, order_token

              @payment_session = SpreeAdyen::PaymentSessions::FindOrCreate.new(
                order: spree_current_order,
                user: spree_current_user,
                payment_method: adyen_gateway,
                amount: permitted_attributes[:amount]
              ).call

              render_serialized_payload { serialize_resource(@payment_session) }
            end

            # GET /api/v2/storefront/adyen/payment_sessions
            def show
              spree_authorize! :show, spree_current_order, order_token

              @payment_session = spree_current_order.payment_sessions.find(params[:id])

              render_serialized_payload { serialize_resource(@payment_session) }
            end

            # PATCH /api/v2/storefront/adyen/payment_sessions/:id
            def update
              spree_authorize! :update, spree_current_order, order_token

              @payment_session = spree_current_order.payment_sessions.find(params[:id])
              @payment_session.update!(permitted_attributes)

              render_serialized_payload { serialize_resource(@payment_session) }
            end

            private

            def permitted_attributes
              params.require(:payment_session).permit(:amount, :adyen_payment_method_id, :off_session)
            end

            def resource_serializer
              Spree::V2::Storefront::PaymentSessionSerializer
            end
          end
        end
      end
    end
  end
end
