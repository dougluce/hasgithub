    express = require 'express'
    http = require 'http'
    app = express()
    CoffeeScript = require 'coffee-script'
    teacup = require 'teacup'
    everyauth = require('everyauth')

    config = require process.env.HOME + '/.gitconfig.json'

    connectConfig =
      src: 'public'
      jsDir: 'js'
      cssDir: 'css'
      jsCompilers: 
        litcoffee: 
          match: /\.js$/
          compileSync: (sourcePath, source) ->
            console.log "Compiling " + sourcePath
            CoffeeScript.compile source, filename: sourcePath, literate: true

    global.cdn_js = (url) ->
      teacup.js("#{js_libs_path}/#{url}")

    global.cdn_css = (url) ->
      teacup.css("#{css_libs_path}/#{url}")

    everyauth.github
      .appId(config[app.settings.env].ghClientId)
      .appSecret(config[app.settings.env].ghSecret)
      .scope('user,repo')
      .findOrCreateUser((session, accessToken, accessTokenExtra, githubUserMetadata) ->
        session.oauth = accessToken
        session.uid = githubUserMetadata.login)
      .redirectPath '/'

    everyauth.oauth2
      .sendResponse (res, data) ->
        redirectTo = data.session.redirectTo
        if redirectTo?
          delete data.session.redirectTo
          res.redirect redirectTo

    everyauth.everymodule.handleLogout (req, res) ->
      req.logout()
      req.session.uid = null
      res.writeHead 303, { 'Location': this.logoutRedirectPath() }
      res.end()

    app.configure ->
      app.set 'views', __dirname + '/views'
      app.locals.pretty = true
      app.use express.bodyParser()
      app.use express.cookieParser()
      app.use express.session secret: '921a556f5927741d9ffa6f791ca0aebce0cc4f2c'
      app.use express.methodOverride()
      app.engine "coffee", require('teacup/lib/express').renderFile
      app.use require('teacup/lib/connect-assets') connectConfig
      app.set 'view engine', 'coffee'
      app.use require('stylus').middleware src: __dirname + '/assets'
      app.use express.static __dirname + '/assets'
      app.use everyauth.middleware()
    
    app.configure 'production', ->
      app.set 'port', process.env.PORT
      global.js_libs_path = '//cdnjs.cloudflare.com/ajax/libs/'
      global.css_libs_path = '//cdnjs.cloudflare.com/ajax/libs/'

    app.configure 'development', ->
      app.set 'port', 33333
      global.js_libs_path = 'cdn'
      global.css_libs_path = 'cdn'
      app.use express.errorHandler()
    
    require('./server/router') app

    http.createServer(app).listen app.get('port'), ->
      console.log "HasGithub server listening on port " + app.get 'port'

    
