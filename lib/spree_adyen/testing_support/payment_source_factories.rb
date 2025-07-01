FactoryBot.define do
  # Credit Card Payment Source
  factory :credit_card_payment_source, class: 'SpreeAdyen::PaymentSources::CreditCard' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        brand: 'visa',
        last4: '4242',
        expiry_month: '12',
        expiry_year: '2025',
        holder_name: 'John Doe'
      }
    end
  end

  # iDEAL Payment Source
  factory :ideal_payment_source, class: 'SpreeAdyen::PaymentSources::Ideal' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        bank: 'INGBNL2A',
        last4: '1234'
      }
    end
  end

  # SOFORT Payment Source
  factory :sofort_payment_source, class: 'SpreeAdyen::PaymentSources::Sofort' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        bank_code: 'DEUTDEFF',
        country_code: 'DE',
        bic: 'DEUTDEFF',
        iban: 'DE89370400440532013000'
      }
    end
  end

  # Bancontact Payment Source
  factory :bancontact_payment_source, class: 'SpreeAdyen::PaymentSources::Bancontact' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        bank_code: '001',
        card_number: '1234567890'
      }
    end
  end

  # Giropay Payment Source
  factory :giropay_payment_source, class: 'SpreeAdyen::PaymentSources::Giropay' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        bank_code: 'DEUTDEFF',
        bic: 'DEUTDEFF',
        account_number: '1234567890'
      }
    end
  end

  # PayPal Payment Source
  factory :paypal_payment_source, class: 'SpreeAdyen::PaymentSources::Paypal' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        payer_id: 'PAYER123',
        payer_email: 'test@example.com',
        payment_id: 'PAY-123456789'
      }
    end
  end

  # Apple Pay Payment Source
  factory :apple_pay_payment_source, class: 'SpreeAdyen::PaymentSources::ApplePay' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        payment_data: 'encrypted_payment_data',
        payment_method: 'Visa',
        transaction_identifier: 'APPLE_PAY_123'
      }
    end
  end

  # Google Pay Payment Source
  factory :google_pay_payment_source, class: 'SpreeAdyen::PaymentSources::GooglePay' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        payment_data: 'encrypted_payment_data',
        payment_method: 'Visa',
        transaction_identifier: 'GOOGLE_PAY_123'
      }
    end
  end

  # Klarna Payment Source
  factory :klarna_payment_source, class: 'SpreeAdyen::PaymentSources::Klarna' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        payment_method_type: 'paynow',
        authorization_token: 'KLARNA_AUTH_123',
        session_id: 'KLARNA_SESSION_123'
      }
    end
  end

  # SEPA Direct Debit Payment Source
  factory :sepa_direct_debit_payment_source, class: 'SpreeAdyen::PaymentSources::SepaDirectDebit' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        iban: 'DE89370400440532013000',
        bic: 'COBADEFFXXX',
        account_holder_name: 'John Doe',
        mandate_id: 'SEPA_MANDATE_123'
      }
    end
  end

  # Alipay Payment Source
  factory :alipay_payment_source, class: 'SpreeAdyen::PaymentSources::Alipay' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        buyer_id: 'ALIPAY_BUYER_123',
        buyer_logon_id: 'test@alipay.com',
        trade_no: 'ALIPAY_TRADE_123'
      }
    end
  end

  # WeChat Pay Payment Source
  factory :wechat_pay_payment_source, class: 'SpreeAdyen::PaymentSources::WechatPay' do
    association :payment_method, factory: :payment_method
    
    public_metadata do
      {
        buyer_id: 'WECHAT_BUYER_123',
        buyer_logon_id: 'test@wechat.com',
        trade_no: 'WECHAT_TRADE_123'
      }
    end
  end
end 