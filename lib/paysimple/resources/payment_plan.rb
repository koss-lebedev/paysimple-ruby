module Paysimple
  class PaymentPlan

    def self.create(opts)
      Paysimple.request(:post, url, opts)
    end

    def self.get(id)
      Paysimple.request(:get, "#{url}/#{id}")
    end

    def self.suspend(id)
      Paysimple.request(:put, "#{url}/#{id}/suspend")
    end

    def self.resume(id)
      Paysimple.request(:put, "#{url}/#{id}/resume")
    end

    def self.delete(id)
      Paysimple.request(:delete, "#{url}/#{id}")
    end

    def self.payments(id)
      Paysimple.request(:get, "#{url}/#{id}/payments")
    end

    def self.find(opts)
      Paysimple.request(:get, url, opts)
    end

  protected

    def self.url
      '/paymentplan'
    end

  end
end