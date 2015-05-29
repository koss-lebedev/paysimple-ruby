module Paysimple
  class Customer

    def self.create(opts)
      Paysimple.request(:post, '/customer', opts)
    end

  end
end