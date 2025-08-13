module SpreeAdyen
  module OneTimeUse
    class MigrateRedirectUrl
      def call
        SpreeAdyen::PaymentSession.joins(order: :store).pluck(:id, :url).each do |session_id, host|
          return_url = Spree::Core::Engine.routes.url_helpers.redirect_adyen_payment_session_url(host: host)
          SpreeAdyen::PaymentSession.find(session_id).update(return_url: return_url)
        end
      end
    end
  end
end