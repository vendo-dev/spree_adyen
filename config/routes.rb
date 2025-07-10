Spree::Core::Engine.add_routes do
  # Adyen payment intents [return url]
  get '/adyen/payment_sessions', to: '/spree_adyen/payment_sessions#show',
                                     as: :adyen_payment_session,
                                     controller: '/spree_adyen/payment_sessions'

  post '/adyen/webhooks', to: '/spree_adyen/webhooks#create', controller: '/spree_adyen/webhooks'

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
