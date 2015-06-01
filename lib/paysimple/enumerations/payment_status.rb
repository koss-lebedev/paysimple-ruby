module Paysimple
  class PaymentStatus

    PENDING = 0
    POSTED = 1
    SETTLED = 2
    FAILED = 3
    VOIDED = 5
    REVERSED = 6
    REVERSE_POSTED = 9
    CHARGEBACK = 10
    AUTHORIZED = 12
    RETURNED = 13
    REVERSE_NSF = 15
    REFUND_SETTLED = 17

  end
end
