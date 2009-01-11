class PcFinancial < BankAccount
  def name
    "PC account #{config[:account_id]}"
  end
  
  def download_data
    # return File.read("#{ENV['HOME']}/Downloads/PCF.qfx")
    
    page = agent.get("https://www.txn.banking.pcfinancial.ca/a/authentication/preSignOn.ams")
    form = page.form("SignOnForm")
    form.cardNumber = config[:userid]
    form.password = config[:password]
    
    page = agent.submit(form, form.buttons.first)
    
    page = agent.get("https://www.txn.banking.pcfinancial.ca/a/banking/accounts/downloadTransactions1.ams")
    form = page.form("DownloadTransactionsForm")
    form['fromAccount'] = config[:account_id]
    submit_button = nil
    form.buttons.each {|b| submit_button = b if b.value = "Download transactions" }
    
    page = agent.submit(form, submit_button)
    
    data = page.body
    
    if data =~ /There are no transactions found that met your request/
      return ""
    else
      return data
    end
  end
end
