module Paysimple
  class CreditCard
    def self.create(opts)
      Paysimple.request(:post, '/account/creditcard', opts)
    end
  end
end