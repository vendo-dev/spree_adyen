class AddRedirectUrlToSpreeAdyenPaymentSessions < ActiveRecord::Migration[7.2]
  def change
    add_column :spree_adyen_payment_sessions, :return_url, :string
    add_index :spree_adyen_payment_sessions, :return_url
  end
end