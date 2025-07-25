module SpreeAdyen
  class Base < Spree.base_class
    self.abstract_class = true
    self.table_name_prefix = 'spree_adyen_'
  end
end
