#!/usr/bin/env ruby

require "#{File.dirname(__FILE__)}/lib/account_base"
require "#{File.dirname(__FILE__)}/lib/bank_account"
require "#{File.dirname(__FILE__)}/lib/credit_card_account"
require "#{File.dirname(__FILE__)}/lib/spreadsheet"

Dir["#{File.dirname(__FILE__)}/accounts/*"].each do |file|
  require file
end

require "#{ENV['HOME']}/.gmoney/config.rb"

spreadsheet = Spreadsheet.new(@gs_key, @gdata_user, @gdata_pass)

@accounts.each do |account|
  begin
    worksheet = account.config[:worksheet]
    puts "Getting data from #{account.name}..."
    txns = account.txns
    puts "Inserting into spreadsheet..." if account.txns.any?
    txns.each do |txn|
      retried = false
      begin
        spreadsheet.add_row(worksheet, txn)
      rescue Exception => e
        if retried
          puts "error: #{e.inspect}"
        else
          retried = true
          puts "error: #{e.inspect}, retrying..."
          retry
        end
      end
      print "."
    end
    puts ""
  rescue Exception => e
    puts "ERROR: \n#{e.inspect}\n#{e.backtrace.join("\n")}"
  end
end
