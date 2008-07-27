require "rubygems"
require "mechanize"
require "ofx-parser"

class AccountBase
  attr :config, true
  
  def initialize(config)
    self.config = config
  end
  
  def get_data
    return if @data
    
    @data = download_data
    
    if @data == ""
      puts "No new transactions."
    else
      puts "downloaded data:"
      puts "#{@data}"
    end
    
    return if @data == ""
    
    @data.gsub!(/\r\n/, "\n")
    @data.gsub!(/:$/, ": ")
    @data.gsub!(/&amp;/, "")
    
    @ofx = OfxParser::OfxParser.parse(@data)
    account = ofx_account(@ofx)
    
    if account && account.statement
      @ofx_txns = account.statement.transactions
      @balance = account.balance
    end
  end
  
  def txns
    get_data
    return [] unless @ofx_txns
    
    txns = @ofx_txns.collect do |t|
      {
        (t.amount.to_f >= 0 ? "deposit" : "withdrawal") => t.amount, 
        "chequenumber" => t.check_number,
        "date" => t.date.strftime("%Y-%m-%d"),
        "transactionid" => t.fit_id,
        "memo" => t.memo,
        "payee" => t.payee,
        "siccode" => t.sic,
        "type" => t.type
      }
    end
    if txns.size > 0
      txns.last["balance"] = @balance
    end
    txns
  end
  
  def get_cookie(name)
    agent.cookies.each do |c|
      if c.to_s =~ /#{name}=(.*)/
        return $1
      end
    end
    return nil
  end
  
  def agent
    @agent ||= WWW::Mechanize.new
    @agent.user_agent_alias = 'Mac FireFox'
    @agent
  end
end
