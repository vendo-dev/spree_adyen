import '@hotwired/turbo-rails'

let application

if (typeof window.Stimulus === "undefined") {
  application = Application.start()
  application.debug = false
  window.Stimulus = application
} else {
  application = window.Stimulus
}

import CheckoutAdyenController from 'spree_adyen/controllers/checkout_adyen_controller' 

application.register('checkout-adyen', CheckoutAdyenController);
