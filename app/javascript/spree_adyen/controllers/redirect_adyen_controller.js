import { Controller } from '@hotwired/stimulus'

export default class extends Controller {

  async connect() {
    await this.initCheckout();
  }

  redirectElement() {
    return document.getElementById('redirect-adyen-container');
  }

  async initCheckout() {
    const { AdyenCheckout  } = window.AdyenWeb;
    const redirectResult = this.element.dataset.redirectResult;
    const session = JSON.parse(this.redirectElement().dataset.checkoutAdyenCheckoutAttrubutes)

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