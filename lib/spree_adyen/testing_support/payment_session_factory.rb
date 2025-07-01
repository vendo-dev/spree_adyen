FactoryBot.define do
  factory :payment_session do#, class: SpreeAdyen::PaymentSession do
    adyen_id { 'pi_123' }
    amount { 100 }
    expires_at { 1.hour.from_now }
    
    association :order

    trait :expired do
      expires_at { 1.hour.ago }
    end
  end
end
