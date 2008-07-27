class CreditCardAccount < AccountBase
  def ofx_account(ofx)
    ofx.credit_card
  end
end