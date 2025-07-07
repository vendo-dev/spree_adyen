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
    validates :order, presence: true
    validates :adyen_id, presence: true, uniqueness: { scope: :order_id }
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validate :expiration_date_cannot_be_in_the_past_or_later_than_24_hours, on: :create

    scope :not_expired, -> { where('expires_at > ?', DateTime.current) }

    state_machine :status, initial: :pending do
      event :complete do
        transition pending: :completed
      end

      event :fail do
        transition pending: :failed
      end
    end

    #
    # Callbacks
    #
    before_validation :set_amount_from_order

    #
    # Delegations
    #
    delegate :store, :currency, to: :order

    private

    def set_amount_from_order
      self.amount = order&.total_minus_store_credits if order.present? && (amount.nil? || amount.zero?)
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
  end
end
