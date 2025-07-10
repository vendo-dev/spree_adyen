module SpreeAdyen
  module PaymentSessions
    class UpdateWithResult
      def initialize(payment_session:, session_result:)
        @payment_session = payment_session
        @session_result = session_result
      end

      def call
        update_payment_session_status
      end

      # TODO: save spree_credit_card with tokenization data

      # [7] pry(#<SpreeAdyen::PaymentSessions::UpdateWithResult>)> status_response.params
      # => {"additionalData"=>
      # {"recurring.recurringDetailReference"=>"FNWJJDBCQM589PV5",
      #  "isCardCommercial"=>"unknown",
      #  "recurringProcessingModel"=>"UnscheduledCardOnFile",
      #  "paymentMethod"=>"mc",
      #  "recurring.shopperReference"=>"002",
      #  "tokenization.store.operationType"=>"created",
      #  "tokenization.shopperReference"=>"002",
      #  "tokenization.storedPaymentMethodId"=>"FNWJJDBCQM589PV5"},
      # "id"=>"CS4BA45C58D93FAC42",
      # "payments"=>[{"amount"=>{"currency"=>"USD", "value"=>4199}, "paymentMethod"=>{"brand"=>"mc", "type"=>"scheme"}, "pspReference"=>"ZFP79C6X58T776V5", "resultCode"=>"Authorised"}],
      # "reference"=>"R145900292",
      # "status"=>"completed"}


      private

      attr_reader :payment_session, :session_result

      def status
        status_response.params.fetch('status')
      end

      def status_response
        @status_response ||= payment_session.payment_method.payment_session_result(payment_session.adyen_id, session_result)
      end

      def update_payment_session_status
        case status
        when 'completed' then payment_session.complete!
        when 'canceled' then payment_session.cancel!
        when 'refused' then payment_session.refuse!
        when 'paymentPending' then payment_session.pending!
        end
      end
    end
  end
end
