require 'spree_core'
require 'spree_extension'
require 'spree_adyen/engine'
require 'spree_adyen/version'
require 'spree_adyen/configuration'
require 'adyen-ruby-api-library'
require 'paranoia'

module SpreeAdyen
  def self.queue
    'default'
  end
end
