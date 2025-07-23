FactoryBot.define do
  factory :payment_session, class: SpreeAdyen::PaymentSession do
    sequence(:adyen_id) { |n| "pi_#{n}" }
    adyen_data { 'a very long string' }
    amount { order.total_minus_store_credits }
    status { 'initial' }
    expires_at { 1.hour.from_now }
    payment_method { create(:adyen_gateway) }

    association :user
    association :order, factory: :order_with_line_items

    trait :expired do
      expires_at { 1.hour.ago }
      skip_expiration_date_validation { true }
    end
  end
end
