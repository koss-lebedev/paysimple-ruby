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

    def self.get(id)
      Paysimple.request(:get, "#{url}/#{id}")
    end

    def self.find(opts)
      Paysimple.request(:get, url, opts)
    end

    def self.payments(id, opts)
      Paysimple.request(:get, "#{url}/#{id}/payments", opts)
    end

    def self.payment_schedules(id, opts)
      Paysimple.request(:get, "#{url}/#{id}/paymentschedules", opts)
    end

  protected

    def self.url
      '/customer'
    end

  end
end