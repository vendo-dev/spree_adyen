import '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'

let application

if (typeof window.Stimulus === "undefined") {
  application = Application.start()
  application.debug = false
  window.Stimulus = application
} else {
  application = window.Stimulus
}

import SpreeAdyenController from 'spree_adyen/controllers/spree_adyen_controller' 

application.register('spree_adyen', SpreeAdyenController)