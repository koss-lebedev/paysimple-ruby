# Ruby client library for Paysimple API v4.0

Ruby client to interact with [PaySimple] API. Detailed API documentation can be found here: [documentation]

## Installation

Execute this command:

```ruby
gem install 'paysimple-ruby'
```

If you're using Rails, simply add this to your `Gemfile` :

```ruby
gem 'paysimple-ruby'
```

## Configuration

Initialize Paysimple client with user id and access token:

```ruby
require 'paysimple'
Paysimple.api_user = '<your api username>'
Paysimple.api_key = '<your api key>
```

By default the library will try to connect to the production endpoint. You can customize this behavior by specifying API endpoint explicitly:

```ruby
Paysimple.api_endpoint = Paysimple::Endpoint::PRODUCTION
```

or 

```ruby
Paysimple.api_endpoint = Paysimple::Endpoint::SANDBOX
```

## Usage examples

###Customer

```ruby
# create new customer
customer = Paysimple::Customer.create({ first_name: 'John', last_name: 'Doe' })

# update customer
updated_customer = Paysimple::Customer.update({ id: customer[:id], first_name: 'John', last_name: 'Smith' })

# get customer by ID
customer = Paysimple::Customer.get(customer[:id])

# find customers
customers = Paysimple::Customer.find({ page: 1, page_size: 10, company: 'ABC company' })

# get customer's payments and payment schedules
payments = Paysimple::Customer.payments(customer[:id], { page_size: 5 })
payment_schedules = Paysimple::Customer.payment_schedules(customer[:id], { page_size: 5 })

# delete customer
Paysimple::Customer.delete(customer[:id])
```

### CreditCard

```ruby
# create credit card
credit_card = Paysimple::CreditCard.create({  
	customer_id: customer[:id],
    credit_card_number: '4111111111111111',
    expiration_date: '12/2021',
    billing_zip_code: '80202',
    issuer: Paysimple::Issuer::VISA,
    is_default: true 
})

# update credit card
updated_credit_card = Paysimple::CreditCard.update({ id: credit_card[:id], ... })

# delete credit card
Paysimple::CreditCard.delete(credit_card[:id])
```

###ACH

```ruby
# create ACH
ach = Paysimple::ACH.create({
	customer_id: customer[:id],
    account_number: '751111111',
    routing_number: '131111114',
    bank_name: 'PaySimple Bank',
    is_checking_account: true,
    is_default: true
})

# update ACH
updated_ach = Paysimple::ACH.update({ id: ach[:id], ... })

# delete ACH
Paysimple::ACH.delete(ach[:id])
```

###Payment

```ruby
# create payment
payment = Paysimple::Payment.create({ amount: 100, account_id: credit_card[:id] })

# get payment
payment = Paysimple::Payment.get(payment[:id])

# void payment
Paysimple::Payment.void(payment[:id])

# refund payment
Paysimple::Payment.refund(payment[:id])

# find payments
payments = Paysimple::Payment.find({ status: 'authorized', page_size: 10 })
```

### RecurringPayment

```ruby
# create recurring payment
recurring_payment = Paysimple::RecurringPayment.create({
	account_id: credit_card[:id],
    payment_amount: 10,
    start_date: Date.today,
    execution_frequency_type: Paysimple::ExecutionFrequencyType::DAILY
})

# get recurring payment
recurring_payment = Paysimple::RecurringPayment.get(recurring_payment[:id])

# suspend recurring payment
Paysimple::RecurringPayment.suspend(recurring_payment[:id])

# resume recurring payment
Paysimple::RecurringPayment.resume(recurring_payment[:id])

# get payments connected with recurring payment
payments = Paysimple::RecurringPayment.payments(recurring_payment[:id])

# find recurring payments
recurring_payments = Paysimple::RecurringPayment.find({ page_size: 10 })

# delete recurring payment
Paysimple::RecurringPayment.delete(payment[:id])
```

###PaymentPlan

```ruby
 # create payment plan
payment_plan = Paysimple::PaymentPlan.create({
	account_id: credit_card[:id],
    total_due_amount: 10,
    total_number_of_payments: 3,
    start_date: Date.today,
    execution_frequency_type: Paysimple::ExecutionFrequencyType::DAILY
})

# get payment plan
payment_plan = Paysimple::PaymentPlan.get(payment_plan[:id])

# suspend payment plan
Paysimple::PaymentPlan.suspend(payment_plan[:id])

# resume payment plan
Paysimple::PaymentPlan.resume(payment_plan[:id])

# get payments connected with payment plan
payments = Paysimple::PaymentPlan.payments(payment_plan[:id])

# find payment plan
payment_plans = Paysimple::PaymentPlan.find({ page_size: 10 })

# delete payment plan
Paysimple::PaymentPlan.delete(payment_plan[:id])
```

[PaySimple]:http://www.paysimple.com
[documentation]:http://developer.paysimple.com/documentation/

