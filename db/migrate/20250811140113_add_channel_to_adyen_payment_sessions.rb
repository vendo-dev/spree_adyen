class AddChannelToAdyenPaymentSessions < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_column :spree_adyen_payment_sessions, :channel, :string
    add_index :spree_adyen_payment_sessions, :channel, algorithm: :concurrently

    SpreeAdyen::PaymentSession.where(channel: nil).update_all(channel: 'Web')
  end
end
