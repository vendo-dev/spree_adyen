pin 'application-spree-adyen', to: 'spree_adyen/application.js', preload: false

pin_all_from SpreeAdyen::Engine.root.join('app/javascript/spree_adyen/controllers'),
             under: 'spree_adyen/controllers',
             to:    'spree_adyen/controllers',
             preload: 'application-spree-adyen'
