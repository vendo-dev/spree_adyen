module SpreeAdyen
  class PaymentSession < Base
    #
    # Associations
    #
    belongs_to :order, class_name: 'Spree::Order'
    belongs_to :payment_method, class_name: 'Spree::PaymentMethod'
    belongs_to :user, class_name: Spree.user_class.name

    #
    # Validations
    #
    validates :order, :payment_method, presence: true
    validates :adyen_id, uniqueness: true, presence: true
    validates :adyen_data, :status, :expires_at, presence: true
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :currency, presence: true
    validate :currency_matches_order_currency

    validate :expiration_date_cannot_be_in_the_past_or_later_than_24_hours, on: :create

    scope :not_expired, -> { where('expires_at > ?', DateTime.current) }

    state_machine :status, initial: :initial do
      event :pending do
        transition %i[initial] => :pending
      end
      event :complete do
        transition %i[pending initial] => :completed
      end
      event :cancel do
        transition %i[pending initial] => :canceled
      end
      event :refuse do
        transition %i[pending initial] => :refused
      end
    end

    #
    # Callbacks
    #
    before_validation :set_amount_from_order
    before_validation :set_currency_from_order

    #
    # Delegations
    #
    delegate :store, :currency, to: :order

    private

    def set_amount_from_order
      self.amount = order&.total_minus_store_credits if order.present? && (amount.nil? || amount.zero?)
    end

    def set_currency_from_order
      self.currency = order&.currency
    end

    def amount_in_cents
      @amount_in_cents ||= money.cents
    end

    def money
      @money ||= Spree::Money.new(amount, currency: currency)
    end

    def expiration_date_cannot_be_in_the_past_or_later_than_24_hours
      errors.add(:expires_at, "can't be in the past") if expires_at.present? && expires_at < DateTime.current

      return unless expires_at.present? && expires_at > 24.hours.from_now

      errors.add(:expires_at, "can't be more than 24 hours from now")
    end

    def currency_matches_order_currency
      errors.add(:currency, "must match order currency") if currency != order&.currency
    end
  end
end
