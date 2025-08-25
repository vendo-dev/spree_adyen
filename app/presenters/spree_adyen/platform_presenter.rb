module SpreeAdyen
  class PlatformPresenter
    def to_h
      {
        externalPlatform: {
          name: 'Spree Commerce',
          version: Spree.version,
          integrator: 'Spree Adyen'
        }
      }
    end
  end
end
