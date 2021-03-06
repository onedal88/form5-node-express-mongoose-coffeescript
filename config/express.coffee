express = require 'express'
session = require 'express-session'
compression = require 'compression'
errorHandler = require 'errorhandler'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
methodOverride = require 'method-override'
favicon = require('serve-favicon')
flash = require 'connect-flash'
helpers = require 'view-helpers'
path = require 'path'
mongoStore = require('connect-mongo')(session)

module.exports = (app, config, passport) ->
  env = process.env.NODE_ENV || 'development'
  app.set('showStackError', true)

  if 'production' == env
    app.use compression
      filter: (req, res) ->
        return /json|text|javascript|css/.test(res.getHeader('Content-Type'))
      level: 9
    
  if 'development' == env
    console.log 'Configuring development environment'
    app.use errorHandler()
    app.locals.pretty = true
  
  app.set 'views', config.root + '/app/views'
  app.set 'view engine', 'jade'

  
  app.use helpers(config.app.name)
  app.use cookieParser()
  
  app.use bodyParser.json()
  app.use bodyParser.urlencoded
    extended: true
    
  # Support for using PUT, DEL etc. in forms using hidden _method field
  app.use methodOverride()

  app.use session
    secret: 'p8zztgch48rehu79jskhm6aj3',
    saveUninitialized: true
    resave: true
    store: new mongoStore
      url: config.db,
      collection : 'sessions'
  
  app.use favicon(path.join(__dirname, '../assets/img/favicon.ico'))

  app.use flash()

  app.use passport.initialize()
  app.use passport.session()

  app.use express.static(path.join(__dirname, '../assets'))
  app.use require('connect-assets')()
