import { Controller } from '@hotwired/stimulus'
import { AdyenCheckout, Dropin } from '@adyen/adyen-web'

export default class extends Controller {
  connect() {
    console.log('Hello, SpreeAdyen!')
    console.log(AdyenCheckout)
  }
}