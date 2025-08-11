class AddChannelToAdynPaymentSessions < ActiveRecord::Migration[7.2]
  def change
    add_column :spree_adyen_payment_sessions, :channel, :string
  end
end
