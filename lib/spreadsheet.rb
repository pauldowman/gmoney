# Adapted from http://rubyforge.org/projects/gdata-ruby

require "rubygems"
require "net/http"

module Net
  class HTTPS < HTTP
    def initialize(address, port = nil)
      super(address, port)
      self.use_ssl = true
    end
  end
end

class Spreadsheet
  GOOGLE_LOGIN_URL = URI.parse('https://www.google.com/accounts/ClientLogin')
  
  def initialize(spreadsheet_id, email, password)
    $VERBOSE = nil

    @spreadsheet_id = spreadsheet_id
    service = 'wise'
    source = 'gdata-ruby'
    @url = 'spreadsheets.google.com'

    response = Net::HTTPS.post_form(GOOGLE_LOGIN_URL,
      {'Email'   => email,
       'Passwd'  => password,
       'source'  => source,
       'service' => service })

    response.error! unless response.kind_of? Net::HTTPSuccess

    @headers = {
     'Authorization' => "GoogleLogin auth=#{response.body.split(/=/).last}",
     'Content-Type'  => 'application/atom+xml'
    }
  end
  
  def visibility
    @headers ? 'private' : 'public'
  end
  
  # def set_worksheet(name)
  #   path = "/feeds/worksheets/#{@spreadsheet_id}/#{visibility}/full"
  #   doc = Hpricot(get(path))
  #   result = (doc/"entry/link[@rel='self'][href]")
  #   pp result
  # end
  
  def request(path)
    response, data = get(path)
    data
  end

  def get(path)
    response, data = http.get(path, @headers)
    raise "error: #{response.inspect}, #{response.body}" unless response.kind_of? Net::HTTPSuccess
    data
  end

  def post(path, entry)
    response = http.post(path, entry, @headers)
    raise "error: #{response.inspect}, #{response.body}" unless response.kind_of? Net::HTTPSuccess
    response
  end

  def put(path, entry)
    h = @headers
    h['X-HTTP-Method-Override'] = 'PUT' # just to be nice, add the method override
    response = http.put(path, entry, h)
    raise "error: #{response.inspect}, #{response.body}" unless response.kind_of? Net::HTTPSuccess
    response
  end

  def http
    conn = Net::HTTP.new(@url, 80)
    #conn.set_debug_output $stderr
    conn
  end
  
  def add_row(worksheet, hash)
    path = "/feeds/list/#{@spreadsheet_id}/#{worksheet}/#{visibility}/full"

    entry = "<?xml version='1.0' ?><entry xmlns='http://www.w3.org/2005/Atom' xmlns:gsx='http://schemas.google.com/spreadsheets/2006/extended'>"
    hash.each_pair do |k,v|
      entry += "<gsx:#{k}>#{v}</gsx:#{k}>"
    end
    entry += "</entry>"
    
    post(path, entry)
  end

end
