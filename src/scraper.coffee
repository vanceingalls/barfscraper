output = ''
casper = require('casper').create()
fs = require('fs')
dir = fs.workingDirectory

forumLink = 'http://www.bayarearidersforum.com/forums/forumdisplay.php?f=72'
jQueryPwd = dir + '/jquery-1.11.1.min.js'

getMatchedListings = -> 
  basehref      = 'http://www.bayarearidersforum.com/forums/showthread.php?t='
  itemSelector  = '#threadslist tr:nth-child(n+4) a[title]'
  searchRE      = /[Cc][Bb][Rr]/

  # filter listings that match search expression
  links = $(itemSelector).filter -> searchRE.test $(@).text()
  
  # contruct output string from titles and links in anchor tags
  links = Array::slice.call(links, 0)
  .map (node) -> 
    $node = $ node
    postID = $node.attr('href').split('&t=')[1]
    $node.text() + ' ' + '\n   ' + basehref + postID

  return " - " + links.join("\n - ") if links.length

# inject jQuery into page
casper.start forumLink, -> casper.page.injectJs jQueryPwd
  
# evaluate script in browser
casper.then -> if output = @evaluate getMatchedListings then @echo output

casper.run()