class AddChannelToAdyenPaymentSessions < ActiveRecord::Migration[7.2]
  def change
    add_column :spree_adyen_payment_sessions, :channel, :string

    SpreeAdyen::PaymentSession.where(channel: nil).update_all(channel: 'Web')

    add_index :spree_adyen_payment_sessions, :channel, algorithm: :concurrently
  end
end
