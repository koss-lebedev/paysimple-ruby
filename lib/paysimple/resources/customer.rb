module Paysimple
  class Customer

    def self.create(opts)
      Paysimple.request(:post, url, opts)
    end

    def self.update(opts)
      Paysimple.request(:put, url, opts)
    end

    def self.delete(id)
      Paysimple.request(:delete, "#{url}/#{id}")
    end

  protected

    def self.url
      '/customer'
    end

  end
end