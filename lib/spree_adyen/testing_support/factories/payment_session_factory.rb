FactoryBot.define do
  factory :payment_session, class: SpreeAdyen::PaymentSession do
    sequence(:adyen_id) { |n| "pi_#{n}" }
    adyen_data { 'a very long string' }
    amount { 100 }
    status { 'initial' }
    expires_at { 1.hour.from_now }
    payment_method { create(:adyen_gateway) }

    association :user
    association :order

    trait :expired do
      expires_at { 1.hour.ago }
    end
  end
end
