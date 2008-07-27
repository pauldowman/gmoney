class IngCanada < BankAccount
  def name
    "ING account #{config[:account_id]}"
  end
  
  def download_data
    # return File.read("#{ENV['HOME']}/Desktop/ing.ofx")
    
    page = agent.get("https://secure.ingdirect.ca/InitialINGDirect.html?command=displayLogin&device=web&locale=en_CA")
    form = page.form("Signin")
    form.ACN = config[:userid]
    
    # c = WEBrick::Cookie.new("Name", "ING%20DIRECT")
    # c.domain = "secure.ingdirect.ca"
    # c.path = "/"
    # agent.cookie_jar.add(URI.parse("https://secure.ingdirect.ca/"), c)
    
    form.submit
    
    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=displayChallengeQuestion")
    
    form = page.form("ChallengeQuestion")
    if page.body =~ /On what street did you grow up?/
      form.Answer = config[:street]
    elsif page.body =~ /What colour was your first car?/
      form.Answer = config[:car]
    elsif page.body =~ /What is your favourite colour?/
      form.Answer = config[:colour]
    end
    
    form.submit
    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=displayPINPad")
    
    form = page.form("Signin")
    form.PIN = config[:password]
    
    form.submit
    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=displayAccountSummary")

    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=displayInitialDownLoadTransactionsCommand")
    form = page.form("MainForm")
    form.ACCT = config[:account_id]
    form.DOWNLOADTYPE = "OFX"
    submit_button = nil
    form.buttons.each {|b| submit_button = b if b.name = "YES, I WANT TO CONTINUE." }
    
    agent.submit(form, submit_button)
    page = agent.get("https://secure.ingdirect.ca/INGDirect.html?command=displayDownLoadTransactionsCommand&fill=1")
    page = agent.click(page.links.text("DownLoad"))
    
    data = page.body
    
    if data =~ /<STMTTRN>/
      return data
    else
      return ""
    end
  end
end