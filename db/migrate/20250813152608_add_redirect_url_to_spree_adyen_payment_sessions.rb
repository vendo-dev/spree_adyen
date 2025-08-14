class AddRedirectUrlToSpreeAdyenPaymentSessions < ActiveRecord::Migration[7.2]
  def change
    add_column :spree_adyen_payment_sessions, :return_url, :string

    SpreeAdyen::PaymentSession.reset_column_information
    SpreeAdyen::PaymentSession.joins(order: :store).pluck(:id, :url).each do |session_id, host|
      return_url = Spree::Core::Engine.routes.url_helpers.redirect_adyen_payment_session_url(host: host)
      SpreeAdyen::PaymentSession.find(session_id).update!(return_url: return_url)
    end

    add_index :spree_adyen_payment_sessions, :return_url
  end
end