require 'spec_helper'

describe Paysimple do

  it 'should create customer' do

    RestClient.proxy = 'http://localhost:8888/'

    Paysimple.api_endpoint = Paysimple::Endpoint::SANDBOX
    Paysimple.api_user = ENV['API_USER']
    Paysimple.api_key = ENV['API_KEY']

    customer = Paysimple::Customer.create({ firstName: 'John', lastName: 'Doe' })
    puts customer.inspect
  end

end