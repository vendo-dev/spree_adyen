FactoryBot.define do
  factory :adyen_gateway, parent: :payment_method, class: SpreeAdyen::Gateway do
    name { 'Adyen' }
    type { 'SpreeAdyen::Gateway' }

    preferences do
      {
        api_key: ENV.fetch('ADYEN_API_KEY', 'sk_test_1234567890'),
        merchant_account: ENV.fetch('ADYEN_MERCHANT_ACCOUNT', 'SpreeCommerceECOM')
      }
    end

    trait :with_apple_domain_association_file do
      transient do
        apple_domain_association_file_path do
          File.join(SpreeAdyen::Engine.root, 'spec', 'fixtures', 'files', 'apple-domain-association-file.txt')
        end
      end

      apple_developer_merchantid_domain_association { Rack::Test::UploadedFile.new(apple_domain_association_file_path) }
    end
  end
end
