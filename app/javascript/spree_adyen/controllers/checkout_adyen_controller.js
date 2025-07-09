import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  async connect() {
    const session = JSON.parse(document.getElementById('dropin-container').dataset.checkoutAdyenCheckoutAttrubutes)
    const eventHandlers = {
      onPaymentCompleted: (result, component) => {
        console.info(result, component);
      },
      onPaymentFailed: (result, component) => {
        console.info(result, component);
      },
      onError: (error, component) => {
        console.error(error.name, error.message, error.stack, component);
      }
    }
    const globalConfiguration = Object.assign(session, eventHandlers)
    const { AdyenCheckout, Dropin, Card, GooglePay, PayPal  } = window.AdyenWeb;
    const checkout = await AdyenCheckout(globalConfiguration);
    const dropinConfiguration = {};
    const dropin = new Dropin(checkout, dropinConfiguration)

    dropin.mount('#dropin-container');
  }
} 