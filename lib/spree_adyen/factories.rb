FactoryBot.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_adyen/factories'

  # Include the payment session factory
  require 'spree_adyen/testing_support/payment_session_factory'
  
  # Include the payment source factories
  require 'spree_adyen/testing_support/payment_source_factories'
  require 'spree_adyen/testing_support/gateway_factory'
end
