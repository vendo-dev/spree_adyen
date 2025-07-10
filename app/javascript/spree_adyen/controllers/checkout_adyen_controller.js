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
    const dropinConfiguration = {
      paymentMethodsConfiguration: {
        card: {
          onPaymentCompleted: (result, component) => {
            // redirect to the payment session endpoint with the session result
            const url = new URL(document.getElementById('dropin-container').dataset.checkoutAdyenPaymentSessionPathValue);
            url.searchParams.set('sessionResult', result.sessionResult);
            window.location.replace(url.href);
          },
          onPaymentFailed: (result, component) => {
            console.info(result, component);
          },
          onError: (error, component) => {
            console.error(error.name, error.message, error.stack, component);
          },
          showPayButton: false,
          hasHolderName: true,
        }
      }
    };
    const dropin = new Dropin(checkout, dropinConfiguration)
    window.dropin = dropin;

    dropin.mount('#dropin-container');

    document.getElementById('checkout-payment-submit').addEventListener('click', (e) => {
      e.preventDefault();
      dropin.submit();
    });
  }
} 