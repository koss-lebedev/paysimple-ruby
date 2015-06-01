require 'spec_helper'

describe Paysimple do

  before(:each) do
    Paysimple.api_endpoint = Paysimple::Endpoint::SANDBOX
    Paysimple.api_user = ENV['API_USER']
    Paysimple.api_key = ENV['API_KEY']
  end

  it 'should create customer' do
    customer = Paysimple::Customer.create({ first_name: 'John', last_name: 'Doe' })
    expect(customer[:id]).not_to be_nil
  end

  it 'should update customer' do
    customer = Paysimple::Customer.create({ first_name: 'John', last_name: 'Doe' })
    updated_customer = Paysimple::Customer.update({ id: customer[:id], first_name: 'John', last_name: 'Smith' })
    expect(updated_customer[:last_name]).to eq('Smith')
  end

  it 'should delete customer' do
    customer = Paysimple::Customer.create({ first_name: 'John', last_name: 'Doe' })
    expect { Paysimple::Customer.delete(customer[:id]) }.to_not raise_error
  end

  it 'should create credit card, collect payment and void it' do
    customer = Paysimple::Customer.create({ first_name: 'John', last_name: 'Doe' })
    credit_card = Paysimple::CreditCard.create({
                                                   customer_id: customer[:id],
                                                   credit_card_number: '4111111111111111',
                                                   expiration_date: '12/2021',
                                                   billing_zip_code: '80202',
                                                   issuer: Paysimple::Issuer::VISA,
                                                   is_default: true
                                               })
    expect(credit_card[:id]).not_to be_nil
    payment = Paysimple::Payment.create(amount: 100, account_id: credit_card[:id])
    expect(payment[:status]).to eq('Authorized')
    void_result = Paysimple::Payment.void(payment[:id])
    expect(void_result[:status]).to eq('Voided')
  end

  it 'should return payments' do
    payments = Paysimple::Payment.find({ page: 1, page_size: 2, lite: false })
    puts payments.inspect
    expect(payments).to be_instance_of(Array)
    expect(payments.size).to be <= 2
  end

  it 'should delete credit card' do
    customer = Paysimple::Customer.create({ first_name: 'John', last_name: 'Doe' })
    credit_card = Paysimple::CreditCard.create({
                                                   customer_id: customer[:id],
                                                   credit_card_number: '4111111111111111',
                                                   expiration_date: '12/2021',
                                                   issuer: Paysimple::Issuer::VISA,
                                                   is_default: true
                                               })
    expect { Paysimple::CreditCard.delete(credit_card[:id]) }.to_not raise_error
  end

  it 'should create and delete ACH account' do
    customer = Paysimple::Customer.create({ first_name: 'John', last_name: 'Doe' })
    ach = Paysimple::ACH.create({
                                    customer_id: customer[:id],
                                    account_number: '751111111',
                                    routing_number: '131111114',
                                    bank_name: 'PaySimple Bank',
                                    is_checking_account: true,
                                    is_default: true
                                })
    expect(ach[:id]).not_to be_nil
    expect { Paysimple::ACH.delete(ach[:id]) }.to_not raise_error
  end

  it 'should work with recurring payment' do
    customer = Paysimple::Customer.create({ first_name: 'John', last_name: 'Doe' })
    credit_card = Paysimple::CreditCard.create({
                                                   customer_id: customer[:id],
                                                   credit_card_number: '4111111111111111',
                                                   expiration_date: '12/2021',
                                                   billing_zip_code: '80202',
                                                   issuer: Paysimple::Issuer::VISA,
                                                   is_default: true
                                               })
    payment = Paysimple::RecurringPayment.create({
                                           account_id: credit_card[:id],
                                           payment_amount: 10,
                                           start_date: Date.today,
                                           execution_frequency_type: Paysimple::ExecutionFrequencyType::DAILY
                                       })
    expect(payment[:id]).not_to be_nil
    expect { Paysimple::RecurringPayment.suspend(payment[:id]) }.to_not raise_error
    expect { Paysimple::RecurringPayment.resume(payment[:id]) }.to_not raise_error
    payments = Paysimple::RecurringPayment.payments(payment[:id])
    expect(payments).to be_instance_of(Array)
  end

  it 'should work with payment plans' do
    customer = Paysimple::Customer.create({ first_name: 'John', last_name: 'Doe' })
    credit_card = Paysimple::CreditCard.create({
                                                   customer_id: customer[:id],
                                                   credit_card_number: '4111111111111111',
                                                   expiration_date: '12/2021',
                                                   billing_zip_code: '80202',
                                                   issuer: Paysimple::Issuer::VISA,
                                                   is_default: true
                                               })
    payment_plan = Paysimple::PaymentPlan.create({
                                                     account_id: credit_card[:id],
                                                     total_due_amount: 10,
                                                     total_number_of_payments: 3,
                                                     start_date: Date.today,
                                                     execution_frequency_type: Paysimple::ExecutionFrequencyType::DAILY
                                                 })
    expect(payment_plan[:id]).not_to be_nil
    expect { Paysimple::PaymentPlan.suspend(payment_plan[:id]) }.to_not raise_error
    expect { Paysimple::PaymentPlan.resume(payment_plan[:id]) }.to_not raise_error
    payments = Paysimple::PaymentPlan.payments(payment_plan[:id])
    expect(payments).to be_instance_of(Array)
  end

  it 'should raise if API key is not provided' do
    Paysimple.api_key = ''
    expect { Paysimple::Customer.create({first_name: 'John'}) }.to raise_error(Paysimple::AuthenticationError)
  end

  it 'should raise if not all required parameters are provided' do
    expect { Paysimple::Customer.create({first_name: 'John'}) }.to raise_error(Paysimple::InvalidRequestError)
  end

  it 'should raise if API key is invalid' do
    expect do
      Paysimple.api_key = '<invalid key>'
      Paysimple::Customer.create({ first_name: 'John', last_name: 'Doe' })
    end.to raise_error(Paysimple::AuthenticationError)
  end

end