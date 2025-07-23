import { Controller } from '@hotwired/stimulus'
import { AdyenCheckout } from '@adyen/adyen-web/auto'
export default class extends Controller {
  async connect() {
    await this.initCheckout();
  }

  redirectElement() {
    return document.getElementById('dropin-container');
  }

  async initCheckout() {
    const session = JSON.parse(this.redirectElement().dataset.checkoutAdyenCheckoutAttrubutes)
    const urlParams = new URLSearchParams(window.location.search);
    const redirectResult = urlParams.get('redirectResult');

    const eventHandlers = {
      onPaymentCompleted: (result, component) => {
        this.redirectToPaymentSession(result);
      },
      onPaymentFailed: (result, component) => {
        this.redirectToPaymentSession(result);
      },
    }
    const configuration = Object.assign(session, eventHandlers);
    const adyenCheckout = await AdyenCheckout(configuration);
    adyenCheckout.submitDetails({ details: { redirectResult: redirectResult } }); 
  }

  redirectToPaymentSession(result) {
    const url = new URL(this.redirectElement().dataset.checkoutAdyenPaymentSessionPathValue);
    url.searchParams.set('sessionResult', result.sessionResult);
    window.location.replace(url.href);
  }
}
