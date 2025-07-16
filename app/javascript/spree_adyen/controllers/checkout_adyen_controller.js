import { Controller } from '@hotwired/stimulus'

export default class extends Controller {

  async connect() {
    await this.initCheckout();
    await this.initDropin();
    this.initEventHandlers();
  }

  async initCheckout() {
    const session = JSON.parse(document.getElementById('dropin-container').dataset.checkoutAdyenCheckoutAttrubutes)
    const eventHandlers = {
      onPaymentCompleted: (result, _component) => {
        // idk why 3ds are handled here instead of paymentMethodsConfiguration.card.onPaymentCompleted
        this.redirectToPaymentSession(result);
      },
      onPaymentFailed: (result, component) => {
        this.redirectToPaymentSession(result);
      },
      onError: (error, component) => {
        console.error(error.name, error.message, error.stack, component);
      }
    }
    const { AdyenCheckout  } = window.AdyenWeb;
    const adyenCheckout = await AdyenCheckout(Object.assign(session, eventHandlers));;
    this.adyenCheckout = adyenCheckout;
  }

  redirectToPaymentSession(result) {
    const url = new URL(document.getElementById('dropin-container').dataset.checkoutAdyenPaymentSessionPathValue);
    url.searchParams.set('sessionResult', result.sessionResult);
    window.location.replace(url.href);
  }

  async initDropin() {
    const { Dropin } = window.AdyenWeb;
    const dropinConfiguration = {
      instantPaymentTypes: ['googlepay'],
      paymentMethodsConfiguration: {
        card: {
          onPaymentCompleted: (result, component) => {
            this.redirectToPaymentSession(result);
          },
          onPaymentFailed: (result, component) => {
            this.redirectToPaymentSession(result);
          },
          onError: (error, component) => {
            console.error(error.name, error.message, error.stack, component);
          },
          showPayButton: false,
          hasHolderName: true,
        }
      }
    };
    const dropin = new Dropin(this.adyenCheckout, dropinConfiguration)
    dropin.mount('#dropin-container');
    this.dropin = dropin;
  }

  initEventHandlers() {
    document.getElementById('checkout-payment-submit').addEventListener('click', (e) => {
      e.preventDefault();
      this.dropin.submit();
    });

    document.querySelectorAll('#existing_cards input[type="radio"]').forEach(elem => elem.addEventListener("change", (e) => {
      var enableElement = document.getElementById(e.target.dataset.show)
      var hideElement = document.getElementById(e.target.dataset.hide)
      if (enableElement) { enableElement.classList.remove('hidden') }
      if (hideElement) { hideElement.classList.add('hidden') }
    }))


  }
} 