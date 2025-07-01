Spree::Core::Engine.add_routes do
  # Stripe payment intents
  get '/adyen/payment_sessions/:id', to: '/spree_adyen/payment_sessions#show',
                                      as: :adyen_payment_intent,
                                      controller: '/spree_adyen/payment_sessions'


  #TODO this seems to be global for apple and its already defined in spree_stripe
  #TODO decide on how to handle this

  # get '/.well-known/apple-developer-merchantid-domain-association' => '/spree_adyen/apple_pay_domain_verification#show'
  
  #TODO add adyen webhook for confirming payment sessions


  # Storefront API
  namespace :api, defaults: { format: 'json' } do
    namespace :v2 do
      namespace :storefront do
        namespace :adyen do
          resources :payment_sessions, only: %i[show create update]
        end
      end
    end
  end
end