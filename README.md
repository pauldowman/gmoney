GMoney
======

Automatically download your bank transactions into a Google Spreadsheet
-----------------------------------------------------------------------

[http://github.com/pauldowman/gmoney](http://github.com/pauldowman/gmoney)


GMoney downloads your bank account transactions and inserts them into a Google spreadsheet. You can write additional sheets to generate summaries, spending reports and charts. (I have a pretty complex spreadsheet with spending reports and graphs but I don't know a good way to make that general and shareable, ideas are welcome.)

GMoney requires the [mechanize](http://mechanize.rubyforge.org/mechanize/) and [ofx-parser](http://ofx-parser.rubyforge.org/) gems.

Unless you use one of the banks that I've already written an interface for, you'll need to roll up your sleeves and write a few lines of code to script logging in to your bank and clicking the "download transactions" link. But it's not that hard, it's done using the awesome [mechanize](http://mechanize.rubyforge.org/mechanize/) library. See [accounts/pc_financial.rb](http://github.com/pauldowman/gmoney/tree/master/accounts/pc_financial.rb) for an example. If you do that please send me a patch or pull request and I'll add your bank.

Your account details (login, account id, password, etc) go into $HOME/.gmoney/config.rb


Copyright 2007 - 2011 [Paul Dowman](http://pauldowman.com/) ([@pauldowman](http://twitter.com/pauldowman))


This is free software, and you are welcome to redistribute it under 
certain conditions. This software comes with ABSOLUTELY NO WARRANTY.
See the file named COPYING for details.
