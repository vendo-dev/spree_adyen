FactoryBot.define do
  factory :payment_session, class: SpreeAdyen::PaymentSession do
    adyen_id { 'pi_123' }
    adyen_data { 'a very long string' }
    amount { 100 }
    status { 'initial' }
    expires_at { 1.hour.from_now }
    currency { 'EUR' }
    payment_method { create(:adyen_gateway) }

    association :user
    association :order

    trait :expired do
      expires_at { 1.hour.ago }
    end
  end
end
