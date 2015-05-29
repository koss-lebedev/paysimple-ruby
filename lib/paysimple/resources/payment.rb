module Paysimple
  class Payment

    def self.create(opts)
      Paysimple.request(:post, url, opts)
    end

    def self.void(id)
      Paysimple.request(:put, "#{url}/#{id}/void")
    end

    def self.get(id)
      Paysimple.request(:get, "#{url}/#{id}")
    end

  protected

    def self.url
      '/payment'
    end

  end
end