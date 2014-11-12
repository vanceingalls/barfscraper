nodemailer = require('nodemailer')
{spawn, exec} = require('child_process')
{print} = require('util')
fs = require('fs')
dir = process.cwd()

# create reusable transporter object using SMTP transport
transporter = nodemailer.createTransport
  service: 'Gmail',
  auth: 
    user: 'email@gmail.com',
    pass: 'password01'

# NB! No need to recreate the transporter object. You can use
# the same transporter object for all e-mails

callback = (body)->
  # setup e-mail data with unicode symbols
  mailOptions = 
    #from: 'Barf Scrape <barfscraper@parts4.me>', # sender address
    from: 'Barf Scraper <foo@blurdybloop.com>',
    to: 'sendToEmail@gmail.com', # list of receivers
    subject: 'CBR parts for sale', # Subject line
    text: body, # plaintext body
    html: body # html body

  # send mail with defined transport object
  transporter.sendMail mailOptions, (error, info)->
    if error
      console.log(error)
    else
      console.log('Message sent: ' + info.response)

casper = (callback) ->
  body = ''

  cmd = command 'casperjs', [dir + '/src/scraper.coffee'], ->
    resultsFile = dir + '/results.txt'  

    if body    
      if !fs.existsSync resultsFile 
        fs.writeFile resultsFile, body
        callback body 
      else 
        fileContent = fs.readFileSync resultsFile
        fileContent = fileContent.toString()

        if fileContent != body
          fs.writeFile resultsFile, body
          callback body 
        else 
          console.info 'nothing new'

  cmd.stdout.on 'data', (data) ->
    body += data.toString()

command = (program, args, onExit) ->
  _command = spawn program, args ?= []
  if onExit? then _command.on 'exit', onExit
  _command

casper callback