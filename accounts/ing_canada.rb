class IngCanada < BankAccount
  def download_data
    # return File.read("#{ENV['HOME']}/Downloads/ing.ofx")
    
    page = agent.get("https://secure.ingdirect.ca/InitialINGDirect.html?command=displayLogin&device=web&locale=en_CA")
    form = page.form("Signin")
    form.ACN = config[:userid]
    
    form.submit
    
    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=displayChallengeQuestion")
    
    form = page.form("ChallengeQuestion")
    if page.body =~ /On what street did you grow up\?/
      form.Answer = config[:street]
    elsif page.body =~ /What colour was your first car\?/
      form.Answer = config[:car]
    elsif page.body =~ /What is your favourite colour\?/
      form.Answer = config[:colour]
    elsif page.body =~ /What was the name of your first pet\?/
      form.Answer = config[:pet]
    elsif page.body =~ /What is the name of your childhood best friend\?/
      form.Answer = config[:friend]
    else
      raise "expected to find one of the known challenge questions"
    end
    
    form.submit
    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=displayPIN")
    
    form = page.form("Signin")
    form.PIN = config[:password]
    
    form.submit

    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=PINPADPersonal")
    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=displayAccountSummary")

    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=displayInitialDownLoadTransactionsCommand")
    form = page.form("MainForm")
    form.ACCT = config[:account_id]
    form.DOWNLOADTYPE = "OFX"
    submit_button = nil
    form.buttons.each {|b| submit_button = b if b.name = "YES, I WANT TO CONTINUE." }
    
    agent.submit(form, submit_button)
    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=displayDownLoadTransactionsCommand&fill=1")
    link = page.links.select {|l| l.text == "DownLoad"}.first
    page = agent.click(link)
    
    data = page.body
    
    if data =~ /<STMTTRN>/
      return data
    else
      return ""
    end
  end
end
