module SpreeAdyen
  class AddressPresenter
    def initialize(address)
      @address = address
    end

    def to_h
      {
        city: address['citystring'],
        country: Spree::Country.find_by(name: address['countrystring']),
        zipcode: address['postalCodestring'],
        address1: address['streetstring'],
        address2: address['houseNumberOrNamestring'],
      }
    end

    private

    attr_reader :address
  end
end