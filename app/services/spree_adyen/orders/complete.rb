module SpreeAdyen
  module Orders
    class Complete
      def initialize(payment_session:)
        @payment_session = payment_session
      end

      def call
        return order if order.completed? || order.canceled?

        order.with_lock do
          # needed for quick checkout orders
          order = add_customer_information
          # find or create the payment
          payment = SpreeAdyen::CreatePayment.new(payment_session: payment_session).call
          payment.process!
          Spree::Dependencies.checkout_complete_service.constantize.call(order: order)
        end

        order.reload
      end

      private

      attr_reader :payment_session

      delegate :order, :user, to: :payment_session

      # TODO: update to make it work with autorisation event
      def add_customer_information
        copy_bill_info_to_user if order.user.present?
      end

      def copy_bill_info_to_user
        user = order.user
        user.first_name ||= order.bill_address.first_name
        user.last_name ||= order.bill_address.last_name
        user.phone ||= order.bill_address.phone
        user.bill_address_id ||= order.bill_address.id
        user.save! if user.changed?
      end
    end
  end
end
