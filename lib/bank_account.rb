class BankAccount < AccountBase
  def ofx_account(ofx)
    ofx.bank_account
  end
end