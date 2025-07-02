class SetupSpreeAdyenModels < ActiveRecord::Migration[7.2]
  def change
    create_table :spree_adyen_payment_sessions do |t|
      t.decimal :amount, precision: 10, scale: 2, default: '0.0', null: false
      t.string :currency, null: false
      t.references :order, null: false, foreign_key: { to_table: :spree_orders }
      t.string :status, null: false, index: true
      t.datetime :expires_at, null: false, index: true
      t.bigint :payment_method_id, null: false, index: true
      t.string :adyen_id, null: false, index: true
      t.timestamps

      t.index ['payment_method_id', 'adyen_id'], unique: true
    end
  end
end