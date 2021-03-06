class CibcVisa < CreditCardAccount
  def download_data
    # return File.read("#{ENV['HOME']}/Downloads/cibcvisa.ofx")
    
    agent.keep_alive = false
    
    page = agent.get "https://www.cibconline.cibc.com/olbtxn/authentication/PreSignOn.cibc?locale=en_CA"
    form = page.form("signonForm")
    form.newCardNumber = config[:userid]
    form.pswPassword = config[:password]
    form.securityUID = get_cookie("securityUID")
    form.isPersistentCookieDisabled = "1"
    
    page = form.submit
    
    page = agent.get "https://www.cibconline.cibc.com/olbtxn/accounts/TransactionDownload1.cibc"
    form = page.form("transactionDownloadForm")
    form.selectedFMSPackage = "0"
    page = form.submit
    
    data = page.body
    
    if data =~ /There are no transactions available to download for the account and the date range you have selected/
      return ""
    else
      return data
    end
  end
end
